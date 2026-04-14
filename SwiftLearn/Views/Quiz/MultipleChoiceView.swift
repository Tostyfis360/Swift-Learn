import SwiftUI

// MARK: - MultipleChoiceView
// Handles: multiple_choice, code_completion, identify_error

struct MultipleChoiceView: View {
    let question: Question
    let isAnswered: Bool
    let selectedId: String?
    let onSelect: (String) -> Void

    private var options: [QuestionOption] { question.options ?? [] }

    var body: some View {
        VStack(spacing: 10) {
            ForEach(options) { option in
                OptionButton(
                    option: option,
                    state: buttonState(for: option.id),
                    onTap: {
                        guard !isAnswered else { return }
                        onSelect(option.id)
                    }
                )
                .shake(trigger: isAnswered && selectedId == option.id && !isCorrect(option.id))
                .bounce(trigger: isAnswered && isCorrect(option.id))
            }
        }
    }

    private func isCorrect(_ id: String) -> Bool { id == question.correctId }

    private func buttonState(for id: String) -> OptionButtonState {
        guard isAnswered else {
            return selectedId == id ? .selected : .idle
        }
        if id == question.correctId { return .correct }
        if id == selectedId         { return .wrong }
        return .dimmed
    }
}

// MARK: - TrueFalseView

struct TrueFalseView: View {
    let question: Question
    let isAnswered: Bool
    let selectedId: String?
    let onSelect: (String) -> Void

    var body: some View {
        VStack(spacing: 10) {
            ForEach([("true", "Verdadero", "checkmark.circle.fill"),
                     ("false", "Falso", "xmark.circle.fill")], id: \.0) { id, label, icon in
                let correct = (id == "true") == (question.isTrue ?? false)
                let state: OptionButtonState = {
                    guard isAnswered else {
                        return selectedId == id ? .selected : .idle
                    }
                    if correct             { return .correct }
                    if selectedId == id    { return .wrong }
                    return .dimmed
                }()

                Button {
                    guard !isAnswered else { return }
                    onSelect(id)
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: icon)
                            .font(.body)
                            .foregroundStyle(state.letterForeground)
                            .frame(width: 30, height: 30)
                            .background(state.letterBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        Text(label)
                            .font(.system(.subheadline, design: .rounded).bold())
                            .foregroundStyle(state.foreground)
                        Spacer()

                        if state == .correct {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(AppColors.success)
                        } else if state == .wrong {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(AppColors.error)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 15)
                    .background(state.background)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(state.border, lineWidth: 1.5)
                    )
                }
                .shake(trigger: isAnswered && selectedId == id && !correct)
                .bounce(trigger: isAnswered && correct)
            }
        }
    }
}

// MARK: - OptionButtonState

enum OptionButtonState {
    case idle, selected, correct, wrong, dimmed

    var background: Color {
        switch self {
        case .idle:     return AppColors.surface
        case .selected: return Color(hex: "00D4FF").opacity(0.1)
        case .correct:  return AppColors.success.opacity(0.12)
        case .wrong:    return AppColors.error.opacity(0.12)
        case .dimmed:   return AppColors.surface.opacity(0.4)
        }
    }

    var border: Color {
        switch self {
        case .idle:     return Color.clear
        case .selected: return Color(hex: "00D4FF").opacity(0.7)
        case .correct:  return AppColors.success.opacity(0.8)
        case .wrong:    return AppColors.error.opacity(0.7)
        case .dimmed:   return Color.clear
        }
    }

    var foreground: Color {
        switch self {
        case .idle:     return AppColors.textPrimary
        case .selected: return AppColors.textPrimary
        case .correct:  return AppColors.success
        case .wrong:    return AppColors.error
        case .dimmed:   return AppColors.textSecondary.opacity(0.4)
        }
    }

    var letterForeground: Color {
        switch self {
        case .idle:     return AppColors.textSecondary
        case .selected: return Color(hex: "00D4FF")
        case .correct:  return AppColors.success
        case .wrong:    return AppColors.error
        case .dimmed:   return AppColors.textSecondary.opacity(0.3)
        }
    }

    var letterBackground: Color {
        switch self {
        case .idle:     return Color.white.opacity(0.07)
        case .selected: return Color(hex: "00D4FF").opacity(0.15)
        case .correct:  return AppColors.success.opacity(0.15)
        case .wrong:    return AppColors.error.opacity(0.15)
        case .dimmed:   return Color.white.opacity(0.03)
        }
    }
}

// MARK: - OptionButton

struct OptionButton: View {
    let option: QuestionOption
    let state: OptionButtonState
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Letter badge — rounded square estilo icono iOS
                Text(option.id)
                    .font(.system(.footnote, design: .rounded).bold())
                    .foregroundStyle(state.letterForeground)
                    .frame(width: 30, height: 30)
                    .background(state.letterBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text(option.text)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(state.foreground)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if state == .correct {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppColors.success)
                        .font(.body)
                } else if state == .wrong {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppColors.error)
                        .font(.body)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .background(state.background)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(state.border, lineWidth: 1.5)
            )
            .animation(.easeOut(duration: 0.15), value: state == .selected)
        }
        .disabled(state == .dimmed)
    }
}
