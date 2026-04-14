import SwiftUI

// MARK: - Color hex init

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Shake modifier (for wrong answers)

struct ShakeModifier: ViewModifier {
    let trigger: Bool

    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .onChange(of: trigger) { _, newValue in
                guard newValue else { return }
                withAnimation(.easeInOut(duration: 0.05).repeatCount(6, autoreverses: true)) {
                    offset = 6
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    offset = 0
                }
            }
    }
}

extension View {
    func shake(trigger: Bool) -> some View {
        modifier(ShakeModifier(trigger: trigger))
    }
}

// MARK: - Bounce modifier (for correct answers)

struct BounceModifier: ViewModifier {
    let trigger: Bool

    @State private var scale: CGFloat = 1

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onChange(of: trigger) { _, newValue in
                guard newValue else { return }
                withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
                    scale = 1.06
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                        scale = 1.0
                    }
                }
            }
    }
}

extension View {
    func bounce(trigger: Bool) -> some View {
        modifier(BounceModifier(trigger: trigger))
    }
}

// MARK: - AppColors

enum AppColors {
    static let background        = Color.black
    static let surface           = Color(hex: "1C1C1E")
    static let surfaceElevated   = Color(hex: "2C2C2E")
    static let accent            = Color(hex: "FF6B35")
    static let accentSecondary   = Color(hex: "00D4FF")
    static let success           = Color(hex: "00E676")
    static let error             = Color(hex: "FF3B5C")
    static let textPrimary       = Color(hex: "F0F4F8")
    static let textSecondary     = Color(hex: "8899AA")
    static let codeBackground    = Color(hex: "141414")
}
