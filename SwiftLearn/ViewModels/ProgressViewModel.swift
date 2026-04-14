import Foundation
import SwiftData

// MARK: - ProgressViewModel

@Observable
@MainActor
final class ProgressViewModel {

    var userProgress: UserProgress?
    var modules: [QuizModule] = []

    private let questionBank = QuestionBankService.shared
    private let progressService = ProgressService.shared

    func load(context: ModelContext) {
        modules = questionBank.modules
        userProgress = progressService.fetchOrCreate(in: context)
    }

    // MARK: - Stats

    var totalXP: Int    { userProgress?.totalXP ?? 0 }
    var streak: Int     { userProgress?.currentStreak ?? 0 }
    var level: XPLevel  { userProgress?.level ?? .aprendiz }
    var sessions: Int   { userProgress?.totalSessionsCompleted ?? 0 }

    var levelProgress: Double { userProgress?.levelProgress ?? 0 }
    var xpForCurrent: Int     { userProgress?.xpForCurrentLevel ?? 0 }
    var xpNeeded: Int         { userProgress?.xpNeededForNextLevel ?? 100 }

    var totalQuestions: Int {
        modules.reduce(0) { $0 + $1.questions.count }
    }

    var totalAnswered: Int {
        userProgress?.moduleProgress.reduce(0) { $0 + $1.questionsAnswered } ?? 0
    }

    var totalCorrect: Int {
        userProgress?.moduleProgress.reduce(0) { $0 + $1.questionsCorrect } ?? 0
    }

    var globalAccuracy: Double {
        guard totalAnswered > 0 else { return 0 }
        return Double(totalCorrect) / Double(totalAnswered)
    }

    // MARK: - Per module

    func accuracy(for moduleId: String) -> Double {
        userProgress?.progress(for: moduleId)?.accuracy ?? 0
    }

    func answeredCount(for moduleId: String) -> Int {
        userProgress?.progress(for: moduleId)?.questionsAnswered ?? 0
    }

    func progressValue(for module: QuizModule) -> Double {
        guard let p = userProgress else { return 0 }
        return p.progressValue(for: module.id, totalQuestions: module.questions.count)
    }

    func isCompleted(module: QuizModule) -> Bool {
        userProgress?.progress(for: module.id)?.isCompleted ?? false
    }

    // MARK: - Achievements

    var unlockedAchievements: [Achievement] {
        (userProgress?.unlockedAchievementIds ?? []).compactMap {
            Achievements.achievement(for: $0)
        }
    }

}
