import SwiftUI
import SwiftData

@Observable
class LibraryViewModel {
    var isScanning = false
    var errorMessage: String?

    func startScan(modelContext: ModelContext) {
        // Phase A: PhotoScanService を呼び出してスキャン実装予定
        // 現時点ではサンプルデータで動作確認用
        isScanning = true
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            await MainActor.run {
                insertSampleData(modelContext: modelContext)
                isScanning = false
            }
        }
    }

    private func insertSampleData(modelContext: ModelContext) {
        let samples: [ScannedContent] = [
            ScannedContent(
                localIdentifier: UUID().uuidString,
                extractedText: "成功の鍵は、失敗を恐れずに行動し続けることだ。",
                themes: ["マインドセット", "成功"],
                keywords: ["行動", "失敗", "成功"],
                isScreenshot: true
            ),
            ScannedContent(
                localIdentifier: UUID().uuidString,
                extractedText: "毎朝5分の瞑想があなたの一日を変える。静かな時間が創造性を生む。",
                themes: ["習慣", "健康"],
                keywords: ["瞑想", "朝習慣", "創造性"],
                isScreenshot: true
            ),
            ScannedContent(
                localIdentifier: UUID().uuidString,
                extractedText: "読んだ本の内容を人に説明できなければ、本当に理解したとは言えない。",
                themes: ["学習", "読書"],
                keywords: ["学習", "理解", "読書"],
                isScreenshot: false
            )
        ]
        samples.forEach { modelContext.insert($0) }
        try? modelContext.save()
    }
}
