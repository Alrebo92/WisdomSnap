import SwiftUI
import SwiftData

struct GoalEditView: View {
    let profile: UserInterestProfile?
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var goals: [String] = []
    @State private var newGoal = ""

    var body: some View {
        List {
            Section("理想の目標") {
                ForEach(goals, id: \.self) { goal in
                    Text(goal)
                }
                .onDelete { indexSet in
                    goals.remove(atOffsets: indexSet)
                }

                HStack {
                    TextField("新しい目標を追加", text: $newGoal)
                        .submitLabel(.done)
                        .onSubmit { addGoal() }
                    Button("追加", action: addGoal)
                        .disabled(newGoal.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .navigationTitle("目標の編集")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("保存") {
                    profile?.idealGoals = goals
                    try? modelContext.save()
                    dismiss()
                }
                .fontWeight(.semibold)
            }
        }
        .onAppear {
            goals = profile?.idealGoals ?? []
        }
    }

    private func addGoal() {
        let trimmed = newGoal.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        goals.append(trimmed)
        newGoal = ""
    }
}
