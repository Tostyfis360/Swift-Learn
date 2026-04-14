import SwiftUI

// MARK: - SessionResultView

struct SessionResultView: View {
    let module: QuizModule
    let result: SessionResult
    let onDismiss: () -> Void

    @State private var appeared = false
    @State private var showConfetti = false

    private var moduleColor: Color { Color(hex: module.colorHex) }
    private var isPerfect: Bool { result.correctAnswers == result.totalQuestions }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            if showConfetti { ConfettiView() }

            ScrollView {
                VStack(spacing: 28) {
                    Spacer(minLength: 40)

                    // Main result
                    resultHeader

                    // Stats row
                    statsRow

                    // Achievements earned
                    if !result.newAchievements.isEmpty {
                        achievementsSection
                    }

                    // Module progress
                    moduleInfo

                    Spacer(minLength: 40)

                    // CTA
                    Button(action: onDismiss) {
                        Text("Volver al inicio")
                            .font(.system(.headline, design: .rounded).bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(moduleColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 24)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                appeared = true
            }
            if isPerfect {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showConfetti = true
                }
            }
        }
    }

    // MARK: - Result header

    private var resultHeader: some View {
        VStack(spacing: 16) {
            // Big emoji
            Text(resultEmoji)
                .font(.system(size: 72))
                .scaleEffect(appeared ? 1 : 0.5)
                .opacity(appeared ? 1 : 0)

            Text(resultTitle)
                .font(.system(.title, design: .rounded).bold())
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            // Accuracy ring
            ZStack {
                Circle()
                    .stroke(moduleColor.opacity(0.15), lineWidth: 10)
                    .frame(width: 110, height: 110)

                Circle()
                    .trim(from: 0, to: appeared ? result.accuracy : 0)
                    .stroke(moduleColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 110, height: 110)
                    .animation(.spring(response: 1.0, dampingFraction: 0.7).delay(0.4), value: appeared)

                VStack(spacing: 2) {
                    Text("\(result.accuracyPercent)%")
                        .font(.system(.title2, design: .rounded).bold())
                        .foregroundStyle(moduleColor)
                    Text("aciertos")
                        .font(.caption2)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
    }

    // MARK: - Stats row

    private var statsRow: some View {
        HStack(spacing: 0) {
            statCell(value: "\(result.correctAnswers)/\(result.totalQuestions)", label: "Correctas", icon: "checkmark.circle.fill", color: AppColors.success)
            Divider().frame(height: 40).background(Color.white.opacity(0.08))
            statCell(value: "+\(result.xpEarned)", label: "XP ganado", icon: "bolt.fill", color: Color(hex: "FFB347"))
            Divider().frame(height: 40).background(Color.white.opacity(0.08))
            statCell(value: formatDuration(result.duration), label: "Duración", icon: "clock.fill", color: AppColors.accentSecondary)
        }
        .padding(.vertical, 16)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.06), lineWidth: 1))
    }

    private func statCell(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
            Text(value)
                .font(.system(.headline, design: .rounded).bold())
                .foregroundStyle(AppColors.textPrimary)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Achievements

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Logros desbloqueados", systemImage: "star.fill")
                .font(.system(.subheadline, design: .rounded).bold())
                .foregroundStyle(Color(hex: "FFB347"))

            HStack(spacing: 12) {
                ForEach(result.newAchievements) { ach in
                    AchievementBadgeView(achievement: ach, unlocked: true)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "FFB347").opacity(0.3), lineWidth: 1))
    }

    // MARK: - Module info

    private var moduleInfo: some View {
        HStack(spacing: 12) {
            Text(module.emoji)
                .font(.title2)
            VStack(alignment: .leading, spacing: 3) {
                Text(module.title)
                    .font(.system(.subheadline, design: .rounded).bold())
                    .foregroundStyle(AppColors.textPrimary)
                Text("Sesión completada")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(moduleColor)
        }
        .padding(14)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Helpers

    private var resultEmoji: String {
        switch result.accuracy {
        case 1.0:           return "🏆"
        case 0.8..<1.0:     return "🎯"
        case 0.6..<0.8:     return "💪"
        default:            return "📚"
        }
    }

    private var resultTitle: String {
        switch result.accuracy {
        case 1.0:           return "¡Perfecto!"
        case 0.8..<1.0:     return "¡Muy bien!"
        case 0.6..<0.8:     return "¡Buen trabajo!"
        default:            return "Sigue practicando"
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let mins = Int(duration) / 60
        let secs = Int(duration) % 60
        if mins > 0 { return "\(mins)m \(secs)s" }
        return "\(secs)s"
    }
}

// MARK: - ConfettiView (Canvas + TimelineView, no libraries)

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = ConfettiParticle.generate(count: 80)

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let elapsed = timeline.date.timeIntervalSinceReferenceDate
                for particle in particles {
                    let t = elapsed - particle.startTime
                    guard t > 0 else { continue }
                    let progress = min(t / particle.duration, 1.0)
                    let x = particle.startX * size.width + particle.velocityX * t * size.width
                    let y = particle.startY * size.height + particle.velocityY * t * size.height + 0.5 * 300 * t * t
                    let rotation = Angle(degrees: particle.rotation + particle.rotationSpeed * t * 360)
                    let alpha = progress < 0.7 ? 1.0 : 1.0 - (progress - 0.7) / 0.3

                    context.opacity = alpha
                    var path = Path()
                    path.addRect(CGRect(x: -4, y: -6, width: 8, height: 12))

                    context.drawLayer { ctx in
                        ctx.translateBy(x: x, y: y)
                        ctx.rotate(by: rotation)
                        ctx.fill(path, with: .color(particle.color))
                    }
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

struct ConfettiParticle {
    let startX: Double
    let startY: Double
    let velocityX: Double
    let velocityY: Double
    let rotation: Double
    let rotationSpeed: Double
    let duration: Double
    let startTime: Double
    let color: Color

    static func generate(count: Int) -> [ConfettiParticle] {
        let colors: [Color] = [
            Color(hex: "FF6B35"), Color(hex: "00D4FF"), Color(hex: "00E676"),
            Color(hex: "FFB347"), Color(hex: "A855F7"), Color(hex: "FF3B5C")
        ]
        let now = Date.timeIntervalSinceReferenceDate
        return (0..<count).map { _ in
            ConfettiParticle(
                startX: Double.random(in: 0.1...0.9),
                startY: Double.random(in: -0.3...0.1),
                velocityX: Double.random(in: -0.15...0.15),
                velocityY: Double.random(in: -0.1...0.05),
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: -2...2),
                duration: Double.random(in: 1.5...3.5),
                startTime: now + Double.random(in: 0...0.8),
                color: colors.randomElement()!
            )
        }
    }
}
