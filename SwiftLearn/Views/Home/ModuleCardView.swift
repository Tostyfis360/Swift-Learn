import SwiftUI

// MARK: - ModuleCardView

struct ModuleCardView: View {
    let module: QuizModule
    let progress: Double
    let answeredCount: Int
    let isCompleted: Bool
    let failedCount: Int

    private var moduleColor: Color { Color(hex: module.colorHex) }

    var body: some View {
        HStack(spacing: 16) {
            // Left: emoji + ring + porcentaje badge
            ZStack(alignment: .bottom) {
                ZStack {
                    Circle()
                        .fill(moduleColor.opacity(0.12))
                        .frame(width: 58, height: 58)

                    Text(module.emoji)
                        .font(.system(size: 28))

                    ProgressRingView(
                        progress: progress,
                        color: moduleColor,
                        size: 58,
                        lineWidth: 3,
                        showPercent: false
                    )
                    .opacity(progress > 0 ? 1 : 0)
                }

                if progress > 0 {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(AppColors.surfaceElevated)
                        .clipShape(Capsule())
                        .offset(y: 6)
                }
            }
            .frame(width: 58, height: 66)

            // Middle: info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(module.title)
                        .font(.system(.headline, design: .rounded).bold())
                        .foregroundStyle(AppColors.textPrimary)

                    if isCompleted {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundStyle(AppColors.success)
                    }
                }

                Text(module.description)
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 4)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(moduleColor)
                            .frame(width: geo.size.width * progress, height: 4)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                    }
                }
                .frame(height: 4)

                HStack(spacing: 8) {
                    Text("\(answeredCount)/\(module.questions.count) respondidas")
                        .font(.system(size: 11))
                        .foregroundStyle(AppColors.textSecondary)

                    if failedCount > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.trianglehead.counterclockwise")
                                .font(.system(size: 9))
                            Text("\(failedCount) para repasar")
                                .font(.system(size: 11))
                        }
                        .foregroundStyle(Color(hex: "FFB347"))
                    }
                }
            }

            Spacer()

            // Right: chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [moduleColor.opacity(0.06), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isCompleted ? moduleColor.opacity(0.4) : Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}
