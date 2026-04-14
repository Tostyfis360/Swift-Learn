import Foundation
import SwiftData

// MARK: - HomeViewModel

@Observable
@MainActor
final class HomeViewModel {

    // MARK: - Published state
    var userProgress: UserProgress?
    var modules: [QuizModule] = []
    var isLoading = true

    // MARK: - Dependencies
    private let questionBank = QuestionBankService.shared
    private let progressService = ProgressService.shared

    // MARK: - Load

    func load(context: ModelContext) {
        modules = questionBank.modules
        userProgress = progressService.fetchOrCreate(in: context)
        isLoading = false
    }

    // MARK: - Helpers

    func progressValue(for module: QuizModule) -> Double {
        guard let p = userProgress else { return 0 }
        return p.progressValue(for: module.id, totalQuestions: module.questions.count)
    }

    func answeredCount(for module: QuizModule) -> Int {
        userProgress?.progress(for: module.id)?.questionsAnswered ?? 0
    }

    func isCompleted(module: QuizModule) -> Bool {
        userProgress?.progress(for: module.id)?.isCompleted ?? false
    }

    func failedCount(for module: QuizModule) -> Int {
        guard let p = userProgress else { return 0 }
        return p.progress(for: module.id)?.failedQuestions.count ?? 0
    }

    var totalXP: Int    { userProgress?.totalXP ?? 0 }
    var streak: Int     { userProgress?.currentStreak ?? 0 }
    var level: XPLevel  { userProgress?.level ?? .aprendiz }

    var modulesWithReview: [QuizModule] {
        modules.filter { failedCount(for: $0) > 0 }
    }
}
