import SwiftUI
import SwiftData

@main
struct WisdomSnapApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            ScannedContent.self,
            Suggestion.self,
            UserInterestProfile.self
        ])
    }
}
