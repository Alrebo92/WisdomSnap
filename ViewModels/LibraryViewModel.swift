import SwiftUI
import SwiftData
import Photos

@MainActor
@Observable
class LibraryViewModel {
    var isScanning = false
    var scanProgress: (current: Int, total: Int) = (0, 0)
    var authorizationStatus: PHAuthorizationStatus = .notDetermined
    var errorMessage: String?

    var progressText: String {
        guard scanProgress.total > 0 else { return "スキャン中..." }
        return "\(scanProgress.current) / \(scanProgress.total) 枚"
    }

    func startScan(modelContext: ModelContext) {
        Task {
            let granted = await PhotoScanService.requestAuthorization()
            authorizationStatus = granted
                ? .authorized
                : PHPhotoLibrary.authorizationStatus(for: .readWrite)

            guard authorizationStatus == .authorized || authorizationStatus == .limited else {
                errorMessage = "写真へのアクセスを許可してください（設定 > WisdomSnap）"
                return
            }

            isScanning = true

            // 処理済みIDをメインアクター上で取得
            let processedIds = fetchProcessedIdentifiers(modelContext: modelContext)

            // スキャンは非同期・Sendable な ScannedContentData を受け取る
            let scannedData = await PhotoScanService.scanPhotoLibrary(
                processedIdentifiers: processedIds
            ) { [weak self] current, total in
                Task { @MainActor [weak self] in
                    self?.scanProgress = (current, total)
                }
            }

            // メインアクター上で ScannedContent に変換して保存
            scannedData.map { $0.toModel() }.forEach { modelContext.insert($0) }
            try? modelContext.save()
            isScanning = false
            scanProgress = (0, 0)
        }
    }

    // MARK: - Private

    private func fetchProcessedIdentifiers(modelContext: ModelContext) -> Set<String> {
        let descriptor = FetchDescriptor<ScannedContent>()
        let existing = (try? modelContext.fetch(descriptor)) ?? []
        return Set(existing.map(\.localIdentifier))
    }
}
