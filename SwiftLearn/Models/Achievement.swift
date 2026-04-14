import Foundation

// MARK: - Achievement

struct Achievement: Identifiable {
    let id: String
    let emoji: String
    let title: String
    let description: String
    let condition: AchievementCondition
}

enum AchievementCondition {
    case streak(days: Int)
    case fastAnswers(count: Int, maxSeconds: Double)
    case perfectModule
    case recoverQuestion
    case completeAllModules
    case perfectScore
    case longStreak(days: Int)
}

// MARK: - All Achievements

enum Achievements {
    static let all: [Achievement] = [
        Achievement(
            id: "en_racha",
            emoji: "🔥",
            title: "En Racha",
            description: "3 días consecutivos estudiando",
            condition: .streak(days: 3)
        ),
        Achievement(
            id: "velocista",
            emoji: "⚡",
            title: "Velocista",
            description: "5 respuestas correctas en menos de 30 segundos cada una",
            condition: .fastAnswers(count: 5, maxSeconds: 30)
        ),
        Achievement(
            id: "sin_fallos",
            emoji: "🎯",
            title: "Sin Fallos",
            description: "Completa un módulo sin errores",
            condition: .perfectModule
        ),
        Achievement(
            id: "memoria",
            emoji: "🧠",
            title: "Memoria de Elefante",
            description: "Responde correctamente una pregunta que fallaste antes",
            condition: .recoverQuestion
        ),
        Achievement(
            id: "graduado",
            emoji: "🏆",
            title: "Graduado",
            description: "Completa los 5 módulos",
            condition: .completeAllModules
        ),
        Achievement(
            id: "perfeccionista",
            emoji: "💎",
            title: "Perfeccionista",
            description: "100% de aciertos en cualquier módulo",
            condition: .perfectScore
        ),
        Achievement(
            id: "persistente",
            emoji: "🔄",
            title: "Persistente",
            description: "7 días de racha",
            condition: .longStreak(days: 7)
        )
    ]

    static func achievement(for id: String) -> Achievement? {
        all.first { $0.id == id }
    }
}
