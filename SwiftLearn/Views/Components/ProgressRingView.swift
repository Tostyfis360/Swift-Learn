import SwiftUI

// MARK: - ProgressRingView
// Activity-ring style circular progress indicator

struct ProgressRingView: View {
    let progress: Double     // 0.0 – 1.0
    let color: Color
    var size: CGFloat = 52
    var lineWidth: CGFloat = 5
    var showPercent: Bool = true

    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)

            // Fill
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            if showPercent {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: size * 0.22, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 20) {
        ProgressRingView(progress: 0.0,  color: .cyan)
        ProgressRingView(progress: 0.45, color: Color(hex: "FF6B35"))
        ProgressRingView(progress: 1.0,  color: Color(hex: "00E676"))
    }
    .padding()
    .background(Color(hex: "050A14"))
}
