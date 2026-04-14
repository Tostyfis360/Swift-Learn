import SwiftUI
import SwiftData

// MARK: - HomeView

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @State private var vm = HomeViewModel()

    @State private var selectedModule: QuizModule?

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                if vm.isLoading {
                    ProgressView()
                        .tint(AppColors.accent)
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            headerSection
                            if !vm.modulesWithReview.isEmpty {
                                reviewSection
                            }
                            modulesSection
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .sheet(item: $selectedModule) { module in
                SessionSetupView(module: module)
            }
        }
        .onAppear { vm.load(context: context) }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Tu camino")
                        .font(.system(.title3, design: .rounded).bold())
                        .foregroundStyle(AppColors.textPrimary)
                    Text("Junior → Middle Developer")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                }
                Spacer()

                // Streak badge
                if vm.streak > 0 {
                    VStack(spacing: 2) {
                        Text("🔥")
                            .font(.title3)
                        Text("\(vm.streak)")
                            .font(.system(.caption2, design: .rounded).bold())
                            .foregroundStyle(Color(hex: "FF6B35"))
                    }
                }
            }

            // XP / Level card
            xpCard
        }
        .padding(.top, 8)
    }

    private var xpCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .foregroundStyle(Color(hex: "FFB347"))
                    Text("\(vm.totalXP) XP")
                        .font(.system(.subheadline, design: .rounded).bold())
                        .foregroundStyle(AppColors.textPrimary)
                }

                Spacer()

                Text(vm.level.rawValue)
                    .font(.system(.caption, design: .rounded).bold())
                    .foregroundStyle(Color(hex: vm.level.color))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(Color(hex: vm.level.color).opacity(0.15))
                    )
            }

            // Level progress bar
            if let p = vm.userProgress {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "FF6B35"), Color(hex: "FFB347")],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * p.levelProgress, height: 6)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: p.levelProgress)
                    }
                }
                .frame(height: 6)

                HStack {
                    Text("\(p.xpForCurrentLevel) / \(p.xpNeededForNextLevel) XP")
                        .font(.system(size: 11))
                        .foregroundStyle(AppColors.textSecondary)
                    Spacer()
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(hex: "FF6B35").opacity(0.15), lineWidth: 1)
                )
        )
    }

    // MARK: - Review section

    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Repasar hoy", systemImage: "arrow.trianglehead.counterclockwise")
                .font(.system(.subheadline, design: .rounded).bold())
                .foregroundStyle(Color(hex: "FFB347"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(vm.modulesWithReview) { module in
                        Button {
                            selectedModule = module
                        } label: {
                            HStack(spacing: 8) {
                                Text(module.emoji)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(module.title)
                                        .font(.system(.caption, design: .rounded).bold())
                                        .foregroundStyle(AppColors.textPrimary)
                                    Text("\(vm.failedCount(for: module)) preguntas")
                                        .font(.system(size: 10))
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(hex: "FFB347").opacity(0.12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color(hex: "FFB347").opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Modules section

    private var modulesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Módulos")
                .font(.system(.subheadline, design: .rounded).bold())
                .foregroundStyle(AppColors.textSecondary)

            VStack(spacing: 10) {
                ForEach(vm.modules) { module in
                    Button {
                        selectedModule = module
                    } label: {
                        ModuleCardView(
                            module: module,
                            progress: vm.progressValue(for: module),
                            answeredCount: vm.answeredCount(for: module),
                            isCompleted: vm.isCompleted(module: module),
                            failedCount: vm.failedCount(for: module)
                        )
                    }
                    .sensoryFeedback(.selection, trigger: selectedModule?.id == module.id)
                }
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("Swift Learn")
                .font(.system(.headline, design: .rounded).bold())
                .foregroundStyle(AppColors.textPrimary)
        }
    }
}
