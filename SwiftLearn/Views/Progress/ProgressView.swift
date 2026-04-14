import SwiftUI
import SwiftData

// MARK: - StudyProgressView

struct StudyProgressView: View {
    @Environment(\.modelContext) private var context
    @State private var vm = ProgressViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Summary card
                        summaryCard

                        // Module progress
                        modulesSection

                        // Achievements
                        achievementsSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Progreso")
                        .font(.system(.headline, design: .rounded).bold())
                        .foregroundStyle(AppColors.textPrimary)
                }
            }
        }
        .onAppear { vm.load(context: context) }
    }

    // MARK: - Summary card

    private var summaryCard: some View {
        VStack(spacing: 16) {
            // Level + XP
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(vm.level.rawValue)
                        .font(.system(.title3, design: .rounded).bold())
                        .foregroundStyle(Color(hex: vm.level.color))
                    Text("\(vm.totalXP) XP total")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                // Streak
                VStack(spacing: 4) {
                    Text("🔥")
                        .font(.title2)
                    Text("\(vm.streak) días")
                        .font(.system(.caption, design: .rounded).bold())
                        .foregroundStyle(Color(hex: "FF6B35"))
                }
            }

            // Level progress
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("\(vm.xpForCurrent) / \(vm.xpNeeded) XP")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    Spacer()
                    if vm.level != .senior {
                        Text("Siguiente: \(nextLevelName)")
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 8)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(LinearGradient(
                                colors: [Color(hex: "FF6B35"), Color(hex: "FFB347")],
                                startPoint: .leading, endPoint: .trailing
                            ))
                            .frame(width: geo.size.width * vm.levelProgress, height: 8)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: vm.levelProgress)
                    }
                }
                .frame(height: 8)
            }

            Divider().background(Color.white.opacity(0.06))

            // Stats grid
            HStack(spacing: 0) {
                miniStat(value: "\(vm.totalAnswered)", label: "Respondidas")
                Divider().frame(height: 32).background(Color.white.opacity(0.08))
                miniStat(value: "\(Int(vm.globalAccuracy * 100))%", label: "Precisión")
                Divider().frame(height: 32).background(Color.white.opacity(0.08))
                miniStat(value: "\(vm.sessions)", label: "Sesiones")
            }
        }
        .padding(16)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))
    }

    private func miniStat(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.headline, design: .rounded).bold())
                .foregroundStyle(AppColors.textPrimary)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var nextLevelName: String {
        switch vm.level {
        case .aprendiz: return "Junior"
        case .junior:   return "Mid"
        case .mid:      return "Senior"
        case .senior:   return "Máximo"
        }
    }

    // MARK: - Modules section

    private var modulesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Módulos")
                .font(.system(.subheadline, design: .rounded).bold())
                .foregroundStyle(AppColors.textSecondary)

            VStack(spacing: 8) {
                ForEach(vm.modules) { module in
                    moduleRow(module)
                }
            }
        }
    }

    private func moduleRow(_ module: QuizModule) -> some View {
        let color = Color(hex: module.colorHex)
        let progress = vm.progressValue(for: module)
        let completed = vm.isCompleted(module: module)

        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 44, height: 44)
                Text(module.emoji)
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(module.title)
                        .font(.system(.subheadline, design: .rounded).bold())
                        .foregroundStyle(AppColors.textPrimary)
                    if completed {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundStyle(AppColors.success)
                    }
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.system(.caption, design: .rounded).bold())
                        .foregroundStyle(color)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 4)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(color)
                            .frame(width: geo.size.width * progress, height: 4)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                    }
                }
                .frame(height: 4)

                Text("\(vm.answeredCount(for: module.id))/\(module.questions.count) preguntas · \(Int(vm.accuracy(for: module.id) * 100))% precisión")
                    .font(.system(size: 11))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(12)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.06), lineWidth: 1))
    }

    // MARK: - Achievements section

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Logros")
                    .font(.system(.subheadline, design: .rounded).bold())
                    .foregroundStyle(AppColors.textSecondary)
                Spacer()
                Text("\(vm.unlockedAchievements.count)/\(Achievements.all.count)")
                    .font(.system(.caption, design: .rounded).bold())
                    .foregroundStyle(AppColors.accent)
            }

            let columns = [GridItem(.adaptive(minimum: 80), spacing: 12)]

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(Achievements.all) { ach in
                    AchievementBadgeView(
                        achievement: ach,
                        unlocked: vm.unlockedAchievements.contains(where: { $0.id == ach.id })
                    )
                }
            }
        }
        .padding(16)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))
    }
}
