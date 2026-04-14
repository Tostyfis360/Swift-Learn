import SwiftUI
import SwiftData

// MARK: - SwiftLearnApp

@main
struct SwiftLearnApp: App {

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(for: [UserProgress.self, ModuleProgress.self, FailedQuestion.self])
    }
}

// MARK: - RootTabView

struct RootTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Aprender", systemImage: "book.fill")
                }

            StudyProgressView()
                .tabItem {
                    Label("Progreso", systemImage: "chart.bar.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Ajustes", systemImage: "gearshape.fill")
                }
        }
        .tint(Color(hex: "FF6B35"))
        .preferredColorScheme(.dark)
    }
}
