import SwiftUI
import SwiftData

// MARK: - SessionSetupView

struct SessionSetupView: View {
    let module: QuizModule
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @Query private var allProgress: [UserProgress]

    @State private var selectedLength: SessionLength = .normal
    @State private var showQuiz = false

    private var userProgress: UserProgress {
        if let existing = allProgress.first { return existing }
        let new = UserProgress()
        context.insert(new)
        return new
    }

    private var moduleColor: Color { Color(hex: module.colorHex) }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 28) {
                    // Module header
                    moduleHeader

                    // Session options
                    VStack(spacing: 12) {
                        Text("Elige la duración")
                            .font(.system(.subheadline, design: .rounded).bold())
                            .foregroundStyle(AppColors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(SessionLength.allCases) { length in
                            sessionOption(length)
                        }
                    }

                    Spacer()

                    // Start button
                    Button {
                        showQuiz = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                            Text("Empezar sesión")
                                .font(.system(.headline, design: .rounded).bold())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(moduleColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .sensoryFeedback(.impact(weight: .medium), trigger: showQuiz)
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            .fullScreenCover(isPresented: $showQuiz) {
                QuizView(
                    module: module,
                    sessionLength: selectedLength,
                    userProgress: userProgress,
                    onSessionComplete: { dismiss() }
                )
            }
        }
    }

    // MARK: - Module header

    private var moduleHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(moduleColor.opacity(0.15))
                    .frame(width: 72, height: 72)
                Text(module.emoji)
                    .font(.system(size: 36))
            }

            Text(module.title)
                .font(.system(.title2, design: .rounded).bold())
                .foregroundStyle(AppColors.textPrimary)

            Text(module.description)
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            Text("\(module.questions.count) preguntas disponibles")
                .font(.caption)
                .foregroundStyle(moduleColor)
        }
    }

    // MARK: - Session option card

    private func sessionOption(_ length: SessionLength) -> some View {
        let isSelected = selectedLength == length
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedLength = length
            }
        } label: {
            HStack(spacing: 14) {
                Text(length.emoji)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 3) {
                    Text(length.label)
                        .font(.system(.subheadline, design: .rounded).bold())
                        .foregroundStyle(AppColors.textPrimary)
                    Text(length.subtitle)
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(moduleColor)
                        .font(.title3)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? moduleColor.opacity(0.12) : AppColors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? moduleColor.opacity(0.5) : Color.white.opacity(0.06), lineWidth: 1.5)
            )
        }
        .sensoryFeedback(.selection, trigger: selectedLength)
    }
}
