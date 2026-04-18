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

    /// PHAsset のメタデータからスクリーンショットか判定
    static func isScreenshot(_ asset: PHAsset) -> Bool {
        asset.mediaSubtypes.contains(.photoScreenshot)
    }

    // MARK: - テキスト検出（高速フィルタ）

    /// 画像にテキストが十分含まれているか簡易チェック
    /// - 文字数が minCharCount 未満 → 景色・食事写真と判断してスキップ
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
            // 高速モードで最初のパスだけ流す
            request.recognitionLevel = .fast
            request.recognitionLanguages = ["ja", "en"]

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }

    // MARK: - OCR（精度優先）

    /// 画像からテキストを抽出する
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

    /// 写真ライブラリをスキャンして ScannedContent を生成する
    /// - Parameters:
    ///   - processedIdentifiers: 処理済みの localIdentifier（重複スキップ用）
    ///   - progress: 進捗コールバック (処理済み件数, 総件数)
    /// - Returns: テキストを含む新規 ScannedContent の配列
    static func scanPhotoLibrary(
        processedIdentifiers: Set<String> = [],
        progress: @escaping (Int, Int) -> Void = { _, _ in }
    ) async -> [ScannedContent] {

        // 全写真を取得（新しい順）
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        let total = assets.count
        var results: [ScannedContent] = []
        var processed = 0

        await withTaskGroup(of: ScannedContent?.self) { group in
            // 並列数を制限してメモリを節約
            let batchSize = 5
            var index = 0

            while index < min(total, 300) {  // 最新300枚を上限に処理
                let batchEnd = min(index + batchSize, total)

                for i in index..<batchEnd {
                    let asset = assets.object(at: i)

                    // 処理済みはスキップ
                    guard !processedIdentifiers.contains(asset.localIdentifier) else {
                        processed += 1
                        progress(processed, total)
                        continue
                    }

                    group.addTask {
                        await Self.processAsset(asset)
                    }
                }

                // バッチ分の結果を回収
                for await result in group {
                    processed += 1
                    progress(processed, total)
                    if let content = result {
                        results.append(content)
                    }
                }

                index = batchEnd
            }
        }

        return results
    }

    // MARK: - Private

    private static func processAsset(_ asset: PHAsset) async -> ScannedContent? {
        let screenshot = isScreenshot(asset)

        // サムネイル取得（フィルタ用・保存用）
        guard let image = await fetchImage(asset: asset, targetSize: CGSize(width: 800, height: 800)) else {
            return nil
        }

        // スクリーンショットでない場合は高速テキスト検出でフィルタ
        if !screenshot {
            let hasText = await hasSignificantText(in: image, minCharCount: 30)
            guard hasText else { return nil }
        }

        // OCRでテキスト抽出
        let text = await extractText(from: image)
        guard text.count >= 20 else { return nil }

        // サムネイル用に小さいデータを保存
        let thumbnailData = image.jpegData(compressionQuality: 0.5)

        return ScannedContent(
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
