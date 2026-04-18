import SwiftData
import Foundation

enum SuggestionType: String, Codable {
    case quote  = "格言"
    case habit  = "習慣"
    case action = "アクション"
}

@Model
final class Suggestion {
    var id: UUID
    var content: String
    var type: SuggestionType
    var category: String
    var createdDate: Date
    var isBookmarked: Bool
    var sourceContentIds: [String]  // もとになった ScannedContent の id

    init(
        content: String,
        type: SuggestionType,
        category: String,
        sourceContentIds: [String] = []
    ) {
        self.id = UUID()
        self.content = content
        self.type = type
        self.category = category
        self.createdDate = .now
        self.isBookmarked = false
        self.sourceContentIds = sourceContentIds
    }
}
