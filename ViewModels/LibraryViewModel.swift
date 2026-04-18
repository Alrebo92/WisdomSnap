import SwiftUI
import SwiftData
import Photos

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
            await checkAndRequestAuthorization()
            guard authorizationStatus == .authorized || authorizationStatus == .limited else {
                await MainActor.run {
                    errorMessage = "写真へのアクセスを許可してください（設定 > WisdomSnap）"
                }
                return
            }
            await performScan(modelContext: modelContext)
        }
    }

    // MARK: - Private

    private func checkAndRequestAuthorization() async {
        let granted = await PhotoScanService.requestAuthorization()
        await MainActor.run {
            authorizationStatus = granted
                ? .authorized
                : PHPhotoLibrary.authorizationStatus(for: .readWrite)
        }
    }

    private func performScan(modelContext: ModelContext) async {
        await MainActor.run { isScanning = true }

        // 処理済みの識別子を取得（重複スキップ）
        let processedIds = await fetchProcessedIdentifiers(modelContext: modelContext)

        let newContents = await PhotoScanService.scanPhotoLibrary(
            processedIdentifiers: processedIds
        ) { [weak self] current, total in
            Task { @MainActor in
                self?.scanProgress = (current, total)
            }
        }

        await MainActor.run {
            newContents.forEach { modelContext.insert($0) }
            try? modelContext.save()
            isScanning = false
            scanProgress = (0, 0)
        }
    }

    private func fetchProcessedIdentifiers(modelContext: ModelContext) async -> Set<String> {
        await MainActor.run {
            let descriptor = FetchDescriptor<ScannedContent>()
            let existing = (try? modelContext.fetch(descriptor)) ?? []
            return Set(existing.map(\.localIdentifier))
        }
    }
}
