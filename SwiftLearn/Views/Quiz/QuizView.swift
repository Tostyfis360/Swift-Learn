import SwiftUI
import SwiftData

// MARK: - QuizView

struct QuizView: View {
    let module: QuizModule
    let sessionLength: SessionLength
    let userProgress: UserProgress
    var onSessionComplete: (() -> Void)? = nil

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var vm = QuizViewModel()
    @State private var sessionResult: SessionResult?
    @State private var showResult = false
    @State private var toastAchievement: Achievement?
    @State private var showToast = false
    @State private var isOrderDragging = false

    // Question transition
    @State private var questionKey: Int = 0

    private var moduleColor: Color { Color(hex: module.colorHex) }

    var body: some View {
        ZStack(alignment: .top) {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                topBar

                // Content
                switch vm.state {
                case .idle:
                    ProgressView().tint(moduleColor)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .question:
                    questionContent
                        .id(questionKey)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))

                case .explanation(let wasCorrect):
                    if let q = vm.currentQuestion {
                        ExplanationView(
                            question: q,
                            wasCorrect: wasCorrect,
                            onNext: handleNext,
                            isLast: vm.isLastQuestion
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                case .finished:
                    Color.clear.onAppear { finishSession() }
                }
            }

            // Achievement toast
            if showToast, let ach = toastAchievement {
                VStack {
                    AchievementToast(achievement: ach, isVisible: $showToast)
                        .padding(.top, 8)
                    Spacer()
                }
                .zIndex(10)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onAppear {
            vm.startSession(
                moduleId: module.id,
                length: sessionLength,
                userProgress: userProgress
            )
        }
        .fullScreenCover(isPresented: $showResult) {
            if let result = sessionResult {
                SessionResultView(
                    module: module,
                    result: result,
                    onDismiss: {
                        if let complete = onSessionComplete {
                            complete()
                        } else {
                            dismiss()
                        }
                    }
                )
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: vm.state)
    }

    // MARK: - Top bar

    private var topBar: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(.body, weight: .semibold))
                        .foregroundStyle(AppColors.textSecondary)
                        .frame(width: 36, height: 36)
                        .background(AppColors.surface)
                        .clipShape(Circle())
                }

                Spacer()

                // Module indicator
                HStack(spacing: 6) {
                    Text(module.emoji)
                    Text(module.title)
                        .font(.system(.caption, design: .rounded).bold())
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                // Question counter
                Text("\(vm.currentIndex + 1)/\(vm.totalQuestions)")
                    .font(.system(.caption, design: .rounded).bold())
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(width: 36, alignment: .trailing)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 4)

            XPBarView(
                sessionXP: vm.sessionXP,
                lives: vm.lives,
                progress: vm.sessionProgress
            )
        }
        .background(AppColors.background)
    }

    // MARK: - Question content

    private var questionContent: some View {
        ScrollView {
            if let q = vm.currentQuestion {
                VStack(alignment: .leading, spacing: 16) {
                    // Topic chip
                    HStack {
                        Text(q.topic)
                            .font(.system(.caption2, design: .rounded).bold())
                            .foregroundStyle(moduleColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(moduleColor.opacity(0.12))
                            .clipShape(Capsule())

                        Spacer()

                        difficultyBadge(q.difficulty)
                    }

                    // Question text (true_false uses "statement", others use "question")
                    Text(q.question ?? q.statement ?? "")
                        .font(.system(.title3, design: .rounded).bold())
                        .foregroundStyle(AppColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    // Code snippet (if any)
                    if let code = q.code {
                        CodeBlockView(code: code)
                    } else if let template = q.codeTemplate {
                        CodeBlockView(code: template)
                    } else if let stmt = q.statement {
                        Text("\"" + stmt + "\"")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(AppColors.textPrimary)
                            .italic()
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(moduleColor.opacity(0.2), lineWidth: 1)
                            )
                    }

                    // Answer controls
                    answerControls(for: q)
                }
                .padding(16)
                .padding(.bottom, 24)
            }
        }
        .scrollDisabled(isOrderDragging)
    }

    @ViewBuilder
    private func answerControls(for q: Question) -> some View {
        let isAnswered: Bool = {
            if case .explanation = vm.state { return true }
            return false
        }()

        switch q.type {
        case .multipleChoice, .codeCompletion, .identifyError:
            MultipleChoiceView(
                question: q,
                isAnswered: isAnswered,
                selectedId: vm.selectedOptionId,
                onSelect: { id in
                    withAnimation(.spring(response: 0.3)) {
                        vm.submitAnswer(optionId: id)
                    }
                }
            )

        case .trueFalse:
            TrueFalseView(
                question: q,
                isAnswered: isAnswered,
                selectedId: vm.selectedOptionId,
                onSelect: { id in
                    withAnimation(.spring(response: 0.3)) {
                        vm.submitAnswer(optionId: id)
                    }
                }
            )

        case .orderSteps:
            OrderStepsView(
                question: q,
                isAnswered: isAnswered,
                orderedIndices: Binding(
                    get: {
                        vm.selectedOrderIndices.isEmpty
                            ? Array(0..<(q.steps?.count ?? 0))
                            : vm.selectedOrderIndices
                    },
                    set: { vm.selectedOrderIndices = $0 }
                ),
                isDragging: $isOrderDragging,
                onSubmit: {
                    withAnimation(.spring(response: 0.3)) {
                        vm.submitOrder()
                    }
                }
            )
        }
    }

    // MARK: - Difficulty badge

    private func difficultyBadge(_ difficulty: String) -> some View {
        let color: Color = difficulty.contains("middle") ? Color(hex: "A855F7") : AppColors.accentSecondary
        return Text(difficulty.replacingOccurrences(of: "_to_", with: "→"))
            .font(.system(.caption2, design: .rounded))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.1))
            .clipShape(Capsule())
    }

    // MARK: - Handlers

    private func handleNext() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            vm.nextQuestion()
            questionKey += 1
        }
    }

    private func finishSession() {
        let result = vm.finishSession(context: context, userProgress: userProgress)
        sessionResult = result

        // Show achievement toasts sequentially
        showAchievements(result.newAchievements)
        showResult = true
    }

    private func showAchievements(_ achievements: [Achievement]) {
        guard let first = achievements.first else { return }
        toastAchievement = first
        withAnimation(.spring()) { showToast = true }
    }
}
