import Foundation
import SwiftData

// MARK: - UserProgress (SwiftData root model)

@Model
final class UserProgress {
    var totalXP: Int
    var currentStreak: Int
    var lastStudyDate: Date?
    var totalSessionsCompleted: Int
    var unlockedAchievementIds: [String]

    @Relationship(deleteRule: .cascade)
    var moduleProgress: [ModuleProgress]

    init() {
        totalXP = 0
        currentStreak = 0
        lastStudyDate = nil
        totalSessionsCompleted = 0
        unlockedAchievementIds = []
        moduleProgress = []
    }

    // MARK: - XP Level

    var level: XPLevel {
        switch totalXP {
        case 0..<100:   return .aprendiz
        case 100..<300: return .junior
        case 300..<600: return .mid
        default:        return .senior
        }
    }

    var xpForCurrentLevel: Int {
        switch level {
        case .aprendiz: return totalXP
        case .junior:   return totalXP - 100
        case .mid:      return totalXP - 300
        case .senior:   return totalXP - 600
        }
    }

    var xpNeededForNextLevel: Int {
        switch level {
        case .aprendiz: return 100
        case .junior:   return 200
        case .mid:      return 300
        case .senior:   return 999
        }
    }

    var levelProgress: Double {
        guard xpNeededForNextLevel > 0 else { return 1 }
        return min(Double(xpForCurrentLevel) / Double(xpNeededForNextLevel), 1.0)
    }

    // MARK: - Streak

    func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        guard let last = lastStudyDate else {
            currentStreak = 1
            lastStudyDate = today
            return
        }
        let lastDay = Calendar.current.startOfDay(for: last)
        let diff = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
        switch diff {
        case 0:  break               // ya estudiaste hoy
        case 1:  currentStreak += 1; lastStudyDate = today
        default: currentStreak = 1;  lastStudyDate = today
        }
    }

    // MARK: - Module helpers

    func progress(for moduleId: String) -> ModuleProgress? {
        moduleProgress.first { $0.moduleId == moduleId }
    }

    func progressValue(for moduleId: String, totalQuestions: Int) -> Double {
        guard let p = progress(for: moduleId), totalQuestions > 0 else { return 0 }
        return min(Double(p.questionsAnswered) / Double(totalQuestions), 1.0)
    }
}

// MARK: - XPLevel

enum XPLevel: String {
    case aprendiz = "Aprendiz"
    case junior   = "Junior"
    case mid      = "Mid"
    case senior   = "Senior"

    var color: String {
        switch self {
        case .aprendiz: return "#8899AA"
        case .junior:   return "#00D4FF"
        case .mid:      return "#FF6B35"
        case .senior:   return "#FFD700"
        }
    }
}

// MARK: - ModuleProgress

@Model
final class ModuleProgress {
    var moduleId: String
    var questionsAnswered: Int
    var questionsCorrect: Int
    var lastAccessDate: Date?
    var isCompleted: Bool

    @Relationship(deleteRule: .cascade)
    var failedQuestions: [FailedQuestion]

    init(moduleId: String) {
        self.moduleId = moduleId
        questionsAnswered = 0
        questionsCorrect = 0
        lastAccessDate = nil
        isCompleted = false
        failedQuestions = []
    }

    var accuracy: Double {
        guard questionsAnswered > 0 else { return 0 }
        return Double(questionsCorrect) / Double(questionsAnswered)
    }
}

// MARK: - FailedQuestion

@Model
final class FailedQuestion {
    var questionId: String
    var timesWrong: Int
    var lastAttemptDate: Date
    var nextReviewDate: Date

    init(questionId: String) {
        self.questionId = questionId
        timesWrong = 1
        lastAttemptDate = Date()
        nextReviewDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
    }

    func scheduleNextReview() {
        let hours = timesWrong <= 1 ? 1 : timesWrong <= 3 ? 4 : 24
        nextReviewDate = Calendar.current.date(byAdding: .hour, value: hours, to: Date()) ?? Date()
    }
}
