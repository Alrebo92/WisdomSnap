import SwiftUI

struct ContentView: View {
    @AppStorage("isOnboarded") private var isOnboarded = false

    var body: some View {
        if isOnboarded {
            mainTabView
        } else {
            OnboardingView(isOnboarded: $isOnboarded)
        }
    }

    private var mainTabView: some View {
        TabView {
            HomeView()
                .tabItem { Label("ホーム", systemImage: "sparkles") }
            LibraryView()
                .tabItem { Label("ライブラリ", systemImage: "photo.stack") }
            InsightsView()
                .tabItem { Label("分析", systemImage: "chart.bar.xaxis") }
            SettingsView()
                .tabItem { Label("設定", systemImage: "gearshape") }
        }
    }
}
