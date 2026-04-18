import SwiftData
import Foundation

@Model
final class ScannedContent {
    var id: UUID
    var localIdentifier: String   // PHAsset の識別子
    var extractedText: String
    var capturedDate: Date
    var processedDate: Date
    var themes: [String]          // ["マインドセット", "習慣", "健康" など]
    var keywords: [String]
    var isScreenshot: Bool
    var thumbnailData: Data?

    init(
        localIdentifier: String,
        extractedText: String,
        capturedDate: Date = .now,
        themes: [String] = [],
        keywords: [String] = [],
        isScreenshot: Bool = false,
        thumbnailData: Data? = nil
    ) {
        self.id = UUID()
        self.localIdentifier = localIdentifier
        self.extractedText = extractedText
        self.capturedDate = capturedDate
        self.processedDate = .now
        self.themes = themes
        self.keywords = keywords
        self.isScreenshot = isScreenshot
        self.thumbnailData = thumbnailData
    }
}
