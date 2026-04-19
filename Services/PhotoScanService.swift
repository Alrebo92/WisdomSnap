import Foundation
import Photos
import Vision
import UIKit

class PhotoScanService {

    // MARK: - 権限

    static func requestAuthorization() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        return status == .authorized || status == .limited
    }

    // MARK: - スクリーンショット判定

    static func isScreenshot(_ asset: PHAsset) -> Bool {
        asset.mediaSubtypes.contains(.photoScreenshot)
    }

    // MARK: - テキスト検出（高速フィルタ）

    static func hasSignificantText(in image: UIImage, minCharCount: Int = 20) async -> Bool {
        guard let cgImage = image.cgImage else { return false }

        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { req, error in
                guard error == nil,
                      let observations = req.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: false)
                    return
                }
                let totalChars = observations
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined()
                    .count
                continuation.resume(returning: totalChars >= minCharCount)
            }
            request.recognitionLevel = .fast
            request.recognitionLanguages = ["ja", "en"]
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }

    // MARK: - OCR（精度優先）

    static func extractText(from image: UIImage) async -> String {
        guard let cgImage = image.cgImage else { return "" }

        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { req, error in
                guard error == nil,
                      let observations = req.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }
                let text = observations
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n")
                continuation.resume(returning: text)
            }
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["ja", "en"]
            request.usesLanguageCorrection = true
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }

    // MARK: - ライブラリスキャン

    /// Sendable な ScannedContentData を返す（SwiftDataモデルは非同期境界をまたがせない）
    static func scanPhotoLibrary(
        processedIdentifiers: Set<String> = [],
        progress: @escaping @Sendable (Int, Int) -> Void = { _, _ in }
    ) async -> [ScannedContentData] {

        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        let total = assets.count
        var results: [ScannedContentData] = []
        var processed = 0

        await withTaskGroup(of: ScannedContentData?.self) { group in
            let batchSize = 5
            var index = 0

            while index < min(total, 300) {
                let batchEnd = min(index + batchSize, total)

                for i in index..<batchEnd {
                    let asset = assets.object(at: i)
                    guard !processedIdentifiers.contains(asset.localIdentifier) else {
                        processed += 1
                        progress(processed, total)
                        continue
                    }
                    group.addTask {
                        await Self.processAsset(asset)
                    }
                }

                for await result in group {
                    processed += 1
                    progress(processed, total)
                    if let data = result {
                        results.append(data)
                    }
                }

                index = batchEnd
            }
        }

        return results
    }

    // MARK: - Private

    private static func processAsset(_ asset: PHAsset) async -> ScannedContentData? {
        let screenshot = isScreenshot(asset)

        guard let image = await fetchImage(asset: asset, targetSize: CGSize(width: 800, height: 800)) else {
            return nil
        }

        if !screenshot {
            let hasText = await hasSignificantText(in: image, minCharCount: 30)
            guard hasText else { return nil }
        }

        let text = await extractText(from: image)
        guard text.count >= 20 else { return nil }

        let thumbnailData = image.jpegData(compressionQuality: 0.5)

        return ScannedContentData(
            localIdentifier: asset.localIdentifier,
            extractedText: text,
            capturedDate: asset.creationDate ?? .now,
            isScreenshot: screenshot,
            thumbnailData: thumbnailData
        )
    }

    private static func fetchImage(asset: PHAsset, targetSize: CGSize) async -> UIImage? {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.isSynchronous = false
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true

            PHImageManager.default().requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
}
