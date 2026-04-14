import SwiftUI
import SwiftData

// MARK: - SettingsView

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @State private var showResetAlert = false
    @State private var defaultSession: SessionLength = .normal

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                List {
                    // Study preferences
                    Section {
                        Picker("Sesión por defecto", selection: $defaultSession) {
                            ForEach(SessionLength.allCases) { l in
                                Text(l.label).tag(l)
                            }
                        }
                        .tint(AppColors.accent)
                        .listRowBackground(AppColors.surface)
                    } header: {
                        Text("Preferencias").foregroundStyle(AppColors.textSecondary)
                    }

                    // About
                    Section {
                        LabeledContent("Versión", value: "1.0.0")
                            .foregroundStyle(AppColors.textPrimary)
                            .listRowBackground(AppColors.surface)

                        LabeledContent("Preguntas", value: "\(totalQuestions)")
                            .foregroundStyle(AppColors.textPrimary)
                            .listRowBackground(AppColors.surface)
                    } header: {
                        Text("Información").foregroundStyle(AppColors.textSecondary)
                    }

                    // Danger zone
                    Section {
                        Button(role: .destructive) {
                            showResetAlert = true
                        } label: {
                            Label("Reiniciar progreso", systemImage: "arrow.counterclockwise")
                        }
                        .listRowBackground(AppColors.surface)
                    } header: {
                        Text("Zona de peligro").foregroundStyle(AppColors.textSecondary)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Ajustes")
                        .font(.system(.headline, design: .rounded).bold())
                        .foregroundStyle(AppColors.textPrimary)
                }
            }
            .alert("¿Reiniciar progreso?", isPresented: $showResetAlert) {
                Button("Cancelar", role: .cancel) {}
                Button("Reiniciar", role: .destructive) { resetProgress() }
            } message: {
                Text("Se eliminarán todos tus datos de progreso, XP, rachas y logros. Esta acción no se puede deshacer.")
            }
        }
    }

    private var totalQuestions: Int {
        QuestionBankService.shared.modules.reduce(0) { $0 + $1.questions.count }
    }

    private func resetProgress() {
        ProgressService.shared.reset(in: context)
    }
}
