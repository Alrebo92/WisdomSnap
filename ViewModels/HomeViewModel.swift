import SwiftUI
import SwiftData

@Observable
class HomeViewModel {
    var suggestions: [Suggestion] = []
    var profile: UserInterestProfile?
    var isGenerating = false
    var errorMessage: String?
    var lastUsedLocalEngine = false  // デバッグ・UI表示用

    func load(modelContext: ModelContext) {
        loadProfile(modelContext: modelContext)
        loadSuggestions(modelContext: modelContext)
    }

    /// 新しくスキャンされたコンテンツを分析してプロファイルと提案を更新
    func analyzeAndRefresh(modelContext: ModelContext) {
        guard let profile else { return }
        isGenerating = true

        Task {
            do {
                // 未分析コンテンツ（themes が空）を取得
                let unanalyzed = await fetchUnanalyzedContents(modelContext: modelContext)

                // テーマ・キーワード抽出
                for content in unanalyzed {
                    let (themes, keywords) = try await ClaudeService.analyzeContent(content.extractedText)
                    await MainActor.run {
                        content.themes   = themes
                        content.keywords = keywords
                    }
                }

                // プロファイルのウェイト更新
                await MainActor.run {
                    ClaudeService.updateInterestProfile(profile: profile, newContents: unanalyzed)
                    try? modelContext.save()
                }

                // ハイブリッドエンジンで提案生成
                let recent = await fetchRecentContents(modelContext: modelContext, limit: 20)
                let (newSuggestions, usedLocal) = try await HybridSuggestionEngine.generateSuggestions(
                    profile: profile,
                    recentContents: recent
                )

                await MainActor.run {
                    newSuggestions.forEach { modelContext.insert($0) }
                    try? modelContext.save()
                    lastUsedLocalEngine = usedLocal
                    loadSuggestions(modelContext: modelContext)
                    isGenerating = false
                }

            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isGenerating = false
                }
            }
        }
    }

    // MARK: - Private

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

    private func fetchUnanalyzedContents(modelContext: ModelContext) async -> [ScannedContent] {
        await MainActor.run {
            let descriptor = FetchDescriptor<ScannedContent>()
            let all = (try? modelContext.fetch(descriptor)) ?? []
            return all.filter { $0.themes.isEmpty && !$0.extractedText.isEmpty }
        }
    }

    private func fetchRecentContents(modelContext: ModelContext, limit: Int) async -> [ScannedContent] {
        await MainActor.run {
            var descriptor = FetchDescriptor<ScannedContent>(
                sortBy: [SortDescriptor(\.processedDate, order: .reverse)]
            )
            descriptor.fetchLimit = limit
            return (try? modelContext.fetch(descriptor)) ?? []
        }
    }
}
