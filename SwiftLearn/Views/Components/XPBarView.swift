import SwiftUI

// MARK: - XPBarView
// Shows current session XP and lives

struct XPBarView: View {
    let sessionXP: Int
    let lives: Int
    let progress: Double   // 0.0 – 1.0 of session

    var body: some View {
        HStack(spacing: 12) {
            // Session progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "FF6B35"), Color(hex: "FFB347")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress, height: 6)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: progress)
                }
                .frame(height: 6)
                .frame(maxHeight: .infinity, alignment: .center)
            }
            .frame(height: 20)

            // XP
            HStack(spacing: 3) {
                Image(systemName: "bolt.fill")
                    .font(.caption2)
                    .foregroundStyle(Color(hex: "FFB347"))
                Text("\(sessionXP)")
                    .font(.system(.caption, design: .rounded).bold())
                    .foregroundStyle(Color(hex: "FFB347"))
            }

            // Lives
            HStack(spacing: 2) {
                ForEach(0..<5, id: \.self) { i in
                    Image(systemName: "heart.fill")
                        .font(.caption2)
                        .foregroundStyle(i < lives ? Color(hex: "FF3B5C") : Color.white.opacity(0.2))
                        .scaleEffect(i < lives ? 1 : 0.8)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

#Preview {
    XPBarView(sessionXP: 30, lives: 3, progress: 0.6)
        .background(Color(hex: "0F1923"))
}
