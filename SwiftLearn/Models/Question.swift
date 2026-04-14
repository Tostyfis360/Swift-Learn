import Foundation

// MARK: - Question Types

enum QuestionType: String, Codable {
    case multipleChoice = "multiple_choice"
    case codeCompletion = "code_completion"
    case trueFalse = "true_false"
    case identifyError = "identify_error"
    case orderSteps = "order_steps"
}

// MARK: - Option

struct QuestionOption: Codable, Identifiable {
    let id: String
    let text: String
}

// MARK: - Question

struct Question: Codable, Identifiable {
    let id: String
    let type: QuestionType
    let topic: String
    let difficulty: String
    let question: String?
    let explanation: String
    let tags: [String]

    // Multiple choice / Code completion / Identify error
    let code: String?
    let options: [QuestionOption]?
    let correctId: String?

    // Code completion
    let codeTemplate: String?
    let blankIndex: Int?

    // True/False
    let statement: String?
    let isTrue: Bool?

    // Identify error
    let errorLine: Int?

    // Order steps
    let steps: [String]?
    let correctOrder: [Int]?

    // Shared
    let codeExample: String?
}

// MARK: - Module

struct QuizModule: Codable, Identifiable {
    let id: String
    let title: String
    let emoji: String
    let colorHex: String
    let description: String
    let questions: [Question]
}

// MARK: - QuestionBank root

struct QuestionBank: Codable {
    let modules: [QuizModule]
}
