import SwiftUI

// MARK: - ExplanationView

struct ExplanationView: View {
    let question: Question
    let wasCorrect: Bool
    let onNext: () -> Void
    let isLast: Bool

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            // Result banner
            resultBanner
                .offset(y: appeared ? 0 : -20)
                .opacity(appeared ? 1 : 0)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Explanation section
                    explanationSection

                    // Code example section
                    if let code = question.codeExample {
                        codeSection(code: code)
                    }

                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }

            // Bottom buttons
            bottomActions
        }
        .background(AppColors.background)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }

    // MARK: - Result banner

    private var resultBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: wasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(wasCorrect ? "¡Correcto!" : "Incorrecto")
                    .font(.system(.headline, design: .rounded).bold())
                Text(wasCorrect ? "+10 XP" : "Inténtalo de nuevo más tarde")
                    .font(.caption)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(wasCorrect ? AppColors.success.opacity(0.18) : AppColors.error.opacity(0.18))
        .foregroundStyle(wasCorrect ? AppColors.success : AppColors.error)
    }

    // MARK: - Explanation section

    private var explanationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("¿Por qué?", systemImage: "lightbulb.fill")
                .font(.system(.subheadline, design: .rounded).bold())
                .foregroundStyle(Color(hex: "FFB347"))

            Text(question.explanation)
                .font(.system(.subheadline))
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "FFB347").opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "FFB347").opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Code section

    private func codeSection(code: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("En código:", systemImage: "chevron.left.forwardslash.chevron.right")
                .font(.system(.subheadline, design: .rounded).bold())
                .foregroundStyle(AppColors.accentSecondary)

            CodeBlockView(code: code)
        }
    }

    // MARK: - Bottom actions

    private var bottomActions: some View {
        VStack(spacing: 10) {
            Divider().background(Color.white.opacity(0.06))

            Button(action: onNext) {
                Text(isLast ? "Ver resultados" : "Siguiente")
                    .font(.system(.headline, design: .rounded).bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(wasCorrect ? AppColors.success : AppColors.accent)
                    .foregroundStyle(wasCorrect ? Color.black : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            .sensoryFeedback(.impact(weight: .medium), trigger: true)
        }
        .background(AppColors.background)
    }
}
