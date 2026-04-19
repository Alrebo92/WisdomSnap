import Foundation

/// 非同期境界をまたぐための Sendable な中間データ構造
/// PhotoScanService が返し、ViewModel が ScannedContent に変換する
struct ScannedContentData: Sendable {
    let localIdentifier: String
    let extractedText: String
    let capturedDate: Date
    let isScreenshot: Bool
    let thumbnailData: Data?

    func toModel() -> ScannedContent {
        ScannedContent(
            localIdentifier: localIdentifier,
            extractedText: extractedText,
            capturedDate: capturedDate,
            isScreenshot: isScreenshot,
            thumbnailData: thumbnailData
        )
    }
}
