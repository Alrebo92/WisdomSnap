import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if let profile = viewModel.profile {
                        profileHeaderView(profile: profile)
                    }

                    analyzeButton

                    if viewModel.suggestions.isEmpty {
                        emptyStateView
                    } else {
                        suggestionsSection
                    }
                }
                .padding()
            }
            .navigationTitle("WisdomSnap")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.load(modelContext: modelContext)
            }
            .alert("エラー", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    private func profileHeaderView(profile: UserInterestProfile) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if let goal = profile.idealGoals.first {
                Label(goal, systemImage: "target")
                    .font(.subheadline)
                    .foregroundStyle(.accent)
            }
            Text("スキャン済み: \(profile.totalScannedCount)件")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var analyzeButton: some View {
        Button {
            viewModel.analyzeAndRefresh(modelContext: modelContext)
        } label: {
            HStack {
                if viewModel.isGenerating {
                    ProgressView()
                        .tint(.white)
                    Text("分析中...")
                } else {
                    Image(systemName: "sparkles")
                    Text("スキャン内容を分析して提案を生成")
                    Spacer()
                    if viewModel.lastUsedLocalEngine {
                        Text("オフライン")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(.white.opacity(0.25))
                            .clipShape(Capsule())
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.accent)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(viewModel.isGenerating)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.stack")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("ライブラリタブからスクショをスキャンして\n「分析」ボタンを押してください")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("今日の提案")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.suggestions.count)件")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ForEach(viewModel.suggestions.prefix(5)) { suggestion in
                SuggestionCardView(suggestion: suggestion)
            }
        }
    }
}
