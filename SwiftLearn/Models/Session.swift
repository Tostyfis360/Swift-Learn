import Foundation

// MARK: - Session Length

enum SessionLength: Int, CaseIterable, Identifiable {
    case short  = 5
    case normal = 10
    case intense = 20

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .short:   return "Corta"
        case .normal:  return "Normal"
        case .intense: return "Intensa"
        }
    }

    var subtitle: String {
        switch self {
        case .short:   return "\(rawValue) preguntas · ~3 min"
        case .normal:  return "\(rawValue) preguntas · ~7 min"
        case .intense: return "\(rawValue) preguntas · ~15 min"
        }
    }

    var emoji: String {
        switch self {
        case .short:   return "🌱"
        case .normal:  return "📚"
        case .intense: return "🔥"
        }
    }
}

// MARK: - Session Result

struct SessionResult {
    let moduleId: String
    let totalQuestions: Int
    let correctAnswers: Int
    let xpEarned: Int
    let newAchievements: [Achievement]
    let duration: TimeInterval

    var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions)
    }

    var accuracyPercent: Int {
        Int(accuracy * 100)
    }
}

// MARK: - Answer Record

struct AnswerRecord {
    let questionId: String
    let wasCorrect: Bool
    let timeSpent: TimeInterval
}
