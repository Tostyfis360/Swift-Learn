import SwiftUI

// MARK: - OrderStepsView
// Drag-and-drop to reorder steps

struct OrderStepsView: View {
    let question: Question
    let isAnswered: Bool
    @Binding var orderedIndices: [Int]
    @Binding var isDragging: Bool
    let onSubmit: () -> Void

    private var steps: [String] { question.steps ?? [] }

    @State private var draggingId: Int? = nil
    @State private var dragOffset: CGFloat = 0
    private let rowHeight: CGFloat = 60
    private let rowSpacing: CGFloat = 8

    var body: some View {
        VStack(spacing: 12) {
            // Step list
            VStack(spacing: rowSpacing) {
                ForEach(Array(orderedIndices.enumerated()), id: \.element) { position, stepIndex in
                    StepRow(
                        position: position + 1,
                        text: steps[safe: stepIndex] ?? "",
                        isCorrect: isAnswered ? stepIndex == (question.correctOrder?[safe: position] ?? -1) : nil
                    )
                    .offset(y: draggingId == stepIndex ? dragOffset : 0)
                    .scaleEffect(draggingId == stepIndex ? 1.02 : 1.0)
                    .zIndex(draggingId == stepIndex ? 1 : 0)
                    .shadow(
                        color: draggingId == stepIndex ? Color.black.opacity(0.4) : .clear,
                        radius: 8, y: 4
                    )
                    .animation(
                        draggingId == stepIndex ? nil : .spring(response: 0.25, dampingFraction: 0.7),
                        value: orderedIndices
                    )
                    .gesture(
                        DragGesture(minimumDistance: 5, coordinateSpace: .global)
                            .onChanged { value in
                                guard !isAnswered else { return }
                                if draggingId == nil {
                                    draggingId = stepIndex
                                    isDragging = true
                                }
                                guard draggingId == stepIndex else { return }
                                dragOffset = value.translation.height

                                let step = rowHeight + rowSpacing
                                guard let currentPos = orderedIndices.firstIndex(of: stepIndex) else { return }
                                let displaced = Int((dragOffset / step).rounded())
                                let newPos = max(0, min(orderedIndices.count - 1, currentPos + displaced))

                                if newPos != currentPos {
                                    orderedIndices.move(
                                        fromOffsets: IndexSet(integer: currentPos),
                                        toOffset: newPos > currentPos ? newPos + 1 : newPos
                                    )
                                    dragOffset -= CGFloat(newPos - currentPos) * step
                                }
                            }
                            .onEnded { _ in
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    draggingId = nil
                                    dragOffset = 0
                                }
                                isDragging = false
                            }
                    )
                }
            }

            if !isAnswered {
                Button {
                    onSubmit()
                } label: {
                    Text("Confirmar orden")
                        .font(.system(.subheadline, design: .rounded).bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.accent)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .sensoryFeedback(.impact(weight: .medium), trigger: isAnswered)

                Text("Arrastra para reordenar")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }
}

// MARK: - StepRow

struct StepRow: View {
    let position: Int
    let text: String
    let isCorrect: Bool?

    var body: some View {
        HStack(spacing: 12) {
            // Position number
            ZStack {
                Circle()
                    .fill(rowBackground)
                    .frame(width: 30, height: 30)
                Text("\(position)")
                    .font(.system(.caption, design: .rounded).bold())
                    .foregroundStyle(rowForeground)
            }

            Text(text)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(rowForeground)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)

            if let correct = isCorrect {
                Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(correct ? AppColors.success : AppColors.error)
            } else {
                Image(systemName: "line.3.horizontal")
                    .foregroundStyle(AppColors.textSecondary.opacity(0.5))
                    .font(.caption)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(rowBackground.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(rowBorder, lineWidth: 1.5)
        )
    }

    private var rowBackground: Color {
        guard let correct = isCorrect else { return AppColors.surfaceElevated }
        return correct ? AppColors.success.opacity(0.15) : AppColors.error.opacity(0.15)
    }

    private var rowBorder: Color {
        guard let correct = isCorrect else { return Color.white.opacity(0.08) }
        return correct ? AppColors.success.opacity(0.4) : AppColors.error.opacity(0.4)
    }

    private var rowForeground: Color {
        guard let correct = isCorrect else { return AppColors.textPrimary }
        return correct ? AppColors.success : AppColors.error
    }
}

// MARK: - Safe subscript

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
