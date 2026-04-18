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

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.stack")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("スクショをスキャンして\nあなたの興味を分析しましょう")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日の提案")
                .font(.headline)
            ForEach(viewModel.suggestions.prefix(5)) { suggestion in
                SuggestionCardView(suggestion: suggestion)
            }
        }
    }
}
