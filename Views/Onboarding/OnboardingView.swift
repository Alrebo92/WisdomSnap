import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isOnboarded: Bool
    @State private var goal = ""
    @State private var currentPage = 0

    var body: some View {
        TabView(selection: $currentPage) {
            welcomePage.tag(0)
            goalPage.tag(1)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .ignoresSafeArea()
    }

    private var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "sparkles.rectangle.stack")
                .font(.system(size: 80))
                .foregroundStyle(.accent)
            Text("WisdomSnap")
                .font(.largeTitle.bold())
            Text("スクショを撮り溜めた格言・習慣を分析して\nあなたの理想の自分をサポートします")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Spacer()
            Button("はじめる") {
                withAnimation { currentPage = 1 }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.bottom, 60)
        }
        .padding()
    }

    private var goalPage: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundStyle(.accent)
            Text("理想の目標は？")
                .font(.title.bold())
            Text("最初の目標をひとつ教えてください\n（後からいつでも変更できます）")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            TextField("例: 毎日30分読書する", text: $goal)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            Spacer()
            VStack(spacing: 12) {
                Button("スタート") {
                    setupProfile()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(goal.trimmingCharacters(in: .whitespaces).isEmpty)

                Button("スキップ") {
                    setupProfile()
                }
                .foregroundStyle(.secondary)
            }
            .padding(.bottom, 60)
        }
        .padding()
    }

    private func setupProfile() {
        let trimmed = goal.trimmingCharacters(in: .whitespaces)
        let profile = UserInterestProfile(idealGoals: trimmed.isEmpty ? [] : [trimmed])
        modelContext.insert(profile)
        try? modelContext.save()
        isOnboarded = true
    }
}
