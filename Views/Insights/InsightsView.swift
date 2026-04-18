import SwiftUI
import SwiftData

struct InsightsView: View {
    @Query private var contents: [ScannedContent]
    @Query private var profiles: [UserInterestProfile]

    private var profile: UserInterestProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    statsSection
                    interestSection
                    goalsSection
                }
                .padding()
            }
            .navigationTitle("あなたの分析")
        }
    }

    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCardView(
                title: "スキャン数",
                value: "\(contents.count)",
                icon: "photo.stack"
            )
            StatCardView(
                title: "テーマ数",
                value: "\(Set(contents.flatMap(\.themes)).count)",
                icon: "sparkles"
            )
        }
    }

    private var interestSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("興味・関心マップ")
                .font(.headline)

            if let profile, !profile.topInterests.isEmpty {
                ForEach(profile.topInterests, id: \.category) { interest in
                    InterestBarView(category: interest.category, weight: interest.weight)
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 36))
                        .foregroundStyle(.secondary)
                    Text("スキャンを増やすと\n興味・関心マップが作られます")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            }
        }
    }

    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("理想の目標")
                    .font(.headline)
                Spacer()
                NavigationLink("編集") {
                    GoalEditView(profile: profile)
                }
                .font(.subheadline)
            }

            if let goals = profile?.idealGoals, !goals.isEmpty {
                ForEach(goals, id: \.self) { goal in
                    Label(goal, systemImage: "target")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.secondary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            } else {
                Text("目標をまだ設定していません")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
        }
    }
}
