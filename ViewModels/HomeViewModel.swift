import SwiftUI
import SwiftData

@Observable
class HomeViewModel {
    var suggestions: [Suggestion] = []
    var profile: UserInterestProfile?

    func load(modelContext: ModelContext) {
        loadProfile(modelContext: modelContext)
        loadSuggestions(modelContext: modelContext)
    }

    private func loadProfile(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<UserInterestProfile>()
        profile = try? modelContext.fetch(descriptor).first
        if profile == nil {
            let newProfile = UserInterestProfile()
            modelContext.insert(newProfile)
            profile = newProfile
        }
    }

    private func loadSuggestions(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Suggestion>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        suggestions = (try? modelContext.fetch(descriptor)) ?? []
    }
}
