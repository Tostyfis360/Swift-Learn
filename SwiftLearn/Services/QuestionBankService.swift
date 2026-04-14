import Foundation

// MARK: - QuestionBankService

final class QuestionBankService {
    static let shared = QuestionBankService()
    private init() {}

    private var _bank: QuestionBank?

    var bank: QuestionBank {
        if let cached = _bank { return cached }
        let loaded = load()
        _bank = loaded
        return loaded
    }

    var modules: [QuizModule] { bank.modules }

    func module(for id: String) -> QuizModule? {
        modules.first { $0.id == id }
    }

    func questions(for moduleId: String) -> [Question] {
        module(for: moduleId)?.questions ?? []
    }

    func question(id: String) -> Question? {
        for m in modules {
            if let q = m.questions.first(where: { $0.id == id }) { return q }
        }
        return nil
    }

    // MARK: - Session builder

    /// Returns shuffled questions for a session, prioritising failed ones.
    func buildSession(
        moduleId: String,
        length: SessionLength,
        failedIds: [String]
    ) -> [Question] {
        let pool = questions(for: moduleId)
        guard !pool.isEmpty else { return [] }

        // Separate failed vs fresh
        let failedSet = Set(failedIds)
        let failed  = pool.filter { failedSet.contains($0.id) }.shuffled()
        let fresh   = pool.filter { !failedSet.contains($0.id) }.shuffled()

        // Take up to half from failed (spaced repetition bias)
        let maxFailed = length.rawValue / 2
        let pickedFailed = Array(failed.prefix(maxFailed))
        let remaining   = length.rawValue - pickedFailed.count
        let pickedFresh = Array(fresh.prefix(remaining))

        var session = (pickedFailed + pickedFresh).shuffled()

        // Pad if not enough
        if session.count < length.rawValue {
            let extra = pool
                .filter { q in !session.contains(where: { $0.id == q.id }) }
                .shuffled()
                .prefix(length.rawValue - session.count)
            session += extra
        }

        return Array(session.prefix(length.rawValue))
    }

    // MARK: - Private load

    private func load() -> QuestionBank {
        guard
            let url  = Bundle.main.url(forResource: "QuestionBank", withExtension: "json"),
            let data = try? Data(contentsOf: url)
        else {
            assertionFailure("QuestionBank.json not found in bundle")
            return QuestionBank(modules: [])
        }
        do {
            return try JSONDecoder().decode(QuestionBank.self, from: data)
        } catch {
            assertionFailure("Failed to decode QuestionBank.json: \(error)")
            return QuestionBank(modules: [])
        }
    }
}
