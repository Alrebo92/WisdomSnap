import Foundation
import Photos
import Vision
import UIKit

/// Phase A で実装予定
/// 写真ライブラリをスキャンし、テキスト含有画像を抽出する
class PhotoScanService {

    /// テキスト検出量が閾値を超えるか判定（景色・食事写真を除外）
    /// - Parameter image: 判定対象の画像
    /// - Returns: テキストが十分に含まれる場合 true
    static func hasSignificantText(in image: UIImage, minCharCount: Int = 20) async -> Bool {
        // Phase A: VNRecognizeTextRequest で実装
        // テキスト文字数が minCharCount 以上かチェック
        return false
    }

    /// スクリーンショット判定
    /// - Parameter asset: PHAsset
    /// - Returns: スクリーンショットなら true
    static func isScreenshot(_ asset: PHAsset) -> Bool {
        // Phase A: asset.mediaSubtypes.contains(.photoScreenshot) で判定
        return false
    }

    /// OCR でテキスト抽出
    /// - Parameter image: 対象画像
    /// - Returns: 抽出されたテキスト
    static func extractText(from image: UIImage) async -> String {
        // Phase A: VNRecognizeTextRequest + VNImageRequestHandler で実装
        return ""
    }

    /// 写真ライブラリの全画像をスキャンして ScannedContent を生成
    /// - Returns: テキストを含む画像の配列
    static func scanPhotoLibrary() async -> [ScannedContent] {
        // Phase A で実装
        return []
    }
}
