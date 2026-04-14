import Foundation
import SwiftData

// MARK: - ProgressService

@MainActor
final class ProgressService {
    static let shared = ProgressService()
    private init() {}

    func fetchOrCreate(in context: ModelContext) -> UserProgress {
        let descriptor = FetchDescriptor<UserProgress>()
        let results = (try? context.fetch(descriptor)) ?? []
        if let existing = results.first { return existing }
        let progress = UserProgress()
        context.insert(progress)
        return progress
    }

    // MARK: - Record session result

    func record(
        result: SessionResult,
        progress: UserProgress,
        answers: [AnswerRecord],
        context: ModelContext
    ) -> [Achievement] {
        // Update streak
        progress.updateStreak()
        progress.totalSessionsCompleted += 1
        progress.totalXP += result.xpEarned

        // Find or create module progress
        var modProgress: ModuleProgress
        if let existing = progress.progress(for: result.moduleId) {
            modProgress = existing
        } else {
            modProgress = ModuleProgress(moduleId: result.moduleId)
            progress.moduleProgress.append(modProgress)
        }

        modProgress.lastAccessDate = Date()
        modProgress.questionsAnswered += result.totalQuestions
        modProgress.questionsCorrect  += result.correctAnswers

        // Track failed questions
        for answer in answers where !answer.wasCorrect {
            if let existing = modProgress.failedQuestions.first(where: { $0.questionId == answer.questionId }) {
                existing.timesWrong += 1
                existing.lastAttemptDate = Date()
                existing.scheduleNextReview()
            } else {
                let failed = FailedQuestion(questionId: answer.questionId)
                modProgress.failedQuestions.append(failed)
            }
        }

        // Remove correctly answered questions from failed list
        for answer in answers where answer.wasCorrect {
            modProgress.failedQuestions.removeAll { $0.questionId == answer.questionId }
        }

        // Check completion
        let totalInModule = QuestionBankService.shared.questions(for: result.moduleId).count
        if modProgress.questionsCorrect >= totalInModule {
            modProgress.isCompleted = true
        }

        // Evaluate achievements
        let newAchievements = evaluateAchievements(
            progress: progress,
            modProgress: modProgress,
            answers: answers
        )

        try? context.save()
        return newAchievements
    }

    // MARK: - Achievement evaluation

    private func evaluateAchievements(
        progress: UserProgress,
        modProgress: ModuleProgress,
        answers: [AnswerRecord]
    ) -> [Achievement] {
        var newly: [Achievement] = []

        func unlock(_ id: String) {
            guard !progress.unlockedAchievementIds.contains(id),
                  let ach = Achievements.achievement(for: id) else { return }
            progress.unlockedAchievementIds.append(id)
            newly.append(ach)
        }

        // Streak achievements
        if progress.currentStreak >= 3 { unlock("en_racha") }
        if progress.currentStreak >= 7 { unlock("persistente") }

        // Fast answers: 5 correct under 30s
        let fastCorrect = answers.filter { $0.wasCorrect && $0.timeSpent < 30 }
        if fastCorrect.count >= 5 { unlock("velocista") }

        // Perfect module (no wrong answers in session)
        let allCorrect = answers.allSatisfy { $0.wasCorrect }
        if allCorrect && !answers.isEmpty { unlock("sin_fallos") }

        // Recovered failed question
        let recoveredAny = answers.contains { answer in
            answer.wasCorrect &&
            modProgress.failedQuestions.contains { $0.questionId == answer.questionId }
        }
        if recoveredAny { unlock("memoria") }

        // Perfect score on module
        if modProgress.accuracy >= 1.0 && modProgress.questionsAnswered >= 5 {
            unlock("perfeccionista")
        }

        // All modules completed
        let allCompleted = QuestionBankService.shared.modules.allSatisfy { mod in
            progress.progress(for: mod.id)?.isCompleted == true
        }
        if allCompleted { unlock("graduado") }

        return newly
    }

    // MARK: - Failed question IDs for a module

    func failedQuestionIds(for moduleId: String, progress: UserProgress) -> [String] {
        progress.progress(for: moduleId)?.failedQuestions.map { $0.questionId } ?? []
    }

    // MARK: - Reset all progress

    func reset(in context: ModelContext) {
        let descriptor = FetchDescriptor<UserProgress>()
        if let all = try? context.fetch(descriptor) {
            for item in all { context.delete(item) }
            try? context.save()
        }
    }
}
