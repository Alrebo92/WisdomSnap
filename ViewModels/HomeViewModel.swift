import SwiftUI
import SwiftData

@MainActor
@Observable
class HomeViewModel {
    var suggestions: [Suggestion] = []
    var profile: UserInterestProfile?
    var isGenerating = false
    var errorMessage: String?
    var lastUsedLocalEngine = false

    func load(modelContext: ModelContext) {
        loadProfile(modelContext: modelContext)
        loadSuggestions(modelContext: modelContext)
    }

    func analyzeAndRefresh(modelContext: ModelContext) {
        guard let profile else { return }
        isGenerating = true

        Task {
            do {
                // 未分析コンテンツのテキストだけ取り出す（Sendable な String）
                let unanalyzed = fetchUnanalyzedContents(modelContext: modelContext)
                let texts = unanalyzed.map { $0.extractedText }

                // ClaudeService 呼び出しはメインアクター外でも OK（Sendable な String を渡すだけ）
                var analysisResults: [(themes: [String], keywords: [String])] = []
                for text in texts {
                    let result = try await ClaudeService.analyzeContent(text)
                    analysisResults.append(result)
                }

                // 結果をメインアクター上のモデルに書き戻す
                for (i, content) in unanalyzed.enumerated() where i < analysisResults.count {
                    content.themes   = analysisResults[i].themes
                    content.keywords = analysisResults[i].keywords
                }
                ClaudeService.updateInterestProfile(profile: profile, newContents: unanalyzed)
                try? modelContext.save()

                // 提案生成（プロファイルのコピーだけ渡す）
                let recent = fetchRecentContents(modelContext: modelContext, limit: 20)
                let (newSuggestions, usedLocal) = try await HybridSuggestionEngine.generateSuggestions(
                    profile: profile,
                    recentContents: recent
                )

                newSuggestions.forEach { modelContext.insert($0) }
                try? modelContext.save()
                lastUsedLocalEngine = usedLocal
                loadSuggestions(modelContext: modelContext)
                if let top = newSuggestions.first { WidgetDataService.updateTodaySuggestion(top) }
                isGenerating = false

            } catch {
                errorMessage = error.localizedDescription
                isGenerating = false
            }
        }
    }

    // MARK: - Private（全て @MainActor 上で実行される）

    private func loadProfile(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<UserInterestProfile>()
        profile = try? modelContext.fetch(descriptor).first
        if profile == nil {
            let newProfile = UserInterestProfile()
            modelContext.insert(newProfile)
            profile = newProfile
        }
    }

    private func loadSuggestions(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Suggestion>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        suggestions = (try? modelContext.fetch(descriptor)) ?? []
    }

    private func fetchUnanalyzedContents(modelContext: ModelContext) -> [ScannedContent] {
        let descriptor = FetchDescriptor<ScannedContent>()
        let all = (try? modelContext.fetch(descriptor)) ?? []
        return all.filter { $0.themes.isEmpty && !$0.extractedText.isEmpty }
    }

    private func fetchRecentContents(modelContext: ModelContext, limit: Int) -> [ScannedContent] {
        var descriptor = FetchDescriptor<ScannedContent>(
            sortBy: [SortDescriptor(\.processedDate, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return (try? modelContext.fetch(descriptor)) ?? []
    }
}
