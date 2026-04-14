import SwiftUI

// MARK: - AchievementBadgeView

struct AchievementBadgeView: View {
    let achievement: Achievement
    var unlocked: Bool = true
    var size: CGFloat = 56

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(unlocked
                        ? LinearGradient(
                            colors: [Color(hex: "FF6B35").opacity(0.3), Color(hex: "FF6B35").opacity(0.1)],
                            startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(
                            colors: [Color.white.opacity(0.05), Color.white.opacity(0.03)],
                            startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: size, height: size)

                Circle()
                    .stroke(
                        unlocked ? Color(hex: "FF6B35").opacity(0.5) : Color.white.opacity(0.1),
                        lineWidth: 1.5
                    )
                    .frame(width: size, height: size)

                Text(achievement.emoji)
                    .font(.system(size: size * 0.44))
                    .saturation(unlocked ? 1 : 0)
                    .opacity(unlocked ? 1 : 0.3)
            }

            Text(achievement.title)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(unlocked ? Color(hex: "F0F4F8") : Color(hex: "8899AA"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: size + 10)
        }
    }
}

// MARK: - Achievement Toast (shown when unlocked)

struct AchievementToast: View {
    let achievement: Achievement
    @Binding var isVisible: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text(achievement.emoji)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text("¡Logro desbloqueado!")
                    .font(.system(.caption, design: .rounded).bold())
                    .foregroundStyle(Color(hex: "FF6B35"))
                Text(achievement.title)
                    .font(.system(.subheadline, design: .rounded).bold())
                    .foregroundStyle(Color(hex: "F0F4F8"))
                Text(achievement.description)
                    .font(.caption2)
                    .foregroundStyle(Color(hex: "8899AA"))
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: "162032"))
                .shadow(color: Color(hex: "FF6B35").opacity(0.3), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(hex: "FF6B35").opacity(0.4), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.spring()) { isVisible = false }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 12) {
            AchievementBadgeView(achievement: Achievements.all[0], unlocked: true)
            AchievementBadgeView(achievement: Achievements.all[1], unlocked: false)
            AchievementBadgeView(achievement: Achievements.all[2], unlocked: true)
        }
    }
    .padding()
    .background(Color(hex: "050A14"))
}
