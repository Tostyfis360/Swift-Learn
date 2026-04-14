import Foundation
import SwiftData

// MARK: - Quiz State

enum QuizState {
    case idle
    case question
    case explanation(wasCorrect: Bool)
    case finished
}

extension QuizState: Equatable {
    static func == (lhs: QuizState, rhs: QuizState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.question, .question), (.finished, .finished): return true
        case (.explanation(let a), .explanation(let b)): return a == b
        default: return false
        }
    }
}

// MARK: - QuizViewModel

@Observable
@MainActor
final class QuizViewModel {

    // MARK: - State
    var state: QuizState = .idle
    var currentIndex: Int = 0
    var lives: Int = 5
    var sessionXP: Int = 0
    var answers: [AnswerRecord] = []
    var newAchievements: [Achievement] = []

    // Selected answer tracking
    var selectedOptionId: String?
    var selectedOrderIndices: [Int] = []

    // MARK: - Session data
    private(set) var questions: [Question] = []
    private var moduleId: String = ""
    private var questionStartTime: Date = Date()

    // MARK: - Dependencies
    private let questionBank = QuestionBankService.shared
    private let progressService = ProgressService.shared

    // MARK: - Computed

    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var totalQuestions: Int { questions.count }

    var sessionProgress: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(currentIndex) / Double(totalQuestions)
    }

    var correctAnswers: Int { answers.filter { $0.wasCorrect }.count }

    var isLastQuestion: Bool { currentIndex >= questions.count - 1 }

    // MARK: - Session setup

    func startSession(moduleId: String, length: SessionLength, userProgress: UserProgress) {
        self.moduleId = moduleId
        let failedIds = progressService.failedQuestionIds(for: moduleId, progress: userProgress)
        questions = questionBank.buildSession(moduleId: moduleId, length: length, failedIds: failedIds)
        currentIndex = 0
        lives = 5
        sessionXP = 0
        answers = []
        selectedOptionId = nil
        selectedOrderIndices = []
        state = .question
        questionStartTime = Date()
    }

    // MARK: - Answer submission

    func submitAnswer(optionId: String) {
        guard let q = currentQuestion else { return }
        let timeSpent = Date().timeIntervalSince(questionStartTime)
        let correct: Bool

        switch q.type {
        case .multipleChoice, .codeCompletion, .identifyError:
            correct = optionId == q.correctId
        case .trueFalse:
            correct = (optionId == "true") == (q.isTrue ?? false)
        case .orderSteps:
            correct = false // handled by submitOrder
        }

        selectedOptionId = optionId
        recordAnswer(questionId: q.id, wasCorrect: correct, timeSpent: timeSpent)
    }

    func submitOrder() {
        guard let q = currentQuestion, q.type == .orderSteps else { return }
        let timeSpent = Date().timeIntervalSince(questionStartTime)
        let correct = selectedOrderIndices == q.correctOrder
        recordAnswer(questionId: q.id, wasCorrect: correct, timeSpent: timeSpent)
    }

    private func recordAnswer(questionId: String, wasCorrect: Bool, timeSpent: TimeInterval) {
        let xp = wasCorrect ? 10 : 0
        sessionXP += xp
        if !wasCorrect { lives = max(0, lives - 1) }

        answers.append(AnswerRecord(
            questionId: questionId,
            wasCorrect: wasCorrect,
            timeSpent: timeSpent
        ))

        state = .explanation(wasCorrect: wasCorrect)
    }

    // MARK: - Navigation

    func nextQuestion() {
        selectedOptionId = nil
        selectedOrderIndices = []
        if currentIndex < questions.count - 1 {
            currentIndex += 1
            state = .question
            questionStartTime = Date()
        } else {
            state = .finished
        }
    }

    // MARK: - Finish session

    func finishSession(context: ModelContext, userProgress: UserProgress) -> SessionResult {
        let result = SessionResult(
            moduleId: moduleId,
            totalQuestions: totalQuestions,
            correctAnswers: correctAnswers,
            xpEarned: sessionXP,
            newAchievements: [],
            duration: answers.reduce(0) { $0 + $1.timeSpent }
        )
        let earned = progressService.record(
            result: result,
            progress: userProgress,
            answers: answers,
            context: context
        )
        newAchievements = earned
        return SessionResult(
            moduleId: moduleId,
            totalQuestions: totalQuestions,
            correctAnswers: correctAnswers,
            xpEarned: sessionXP,
            newAchievements: earned,
            duration: result.duration
        )
    }

}
