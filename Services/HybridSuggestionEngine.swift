import Foundation

/// ローカルルールと Claude API を状況に応じて使い分ける提案エンジン
///
/// 判定ロジック:
///   スキャン数 >= 10 かつ ローカル信頼スコア >= 0.6 → ローカル生成（APIコスト0）
///   それ以外 → Claude API にフォールバック
class HybridSuggestionEngine {

    /// ローカル生成を使うための最低スキャン数
    static let localModeMinScans = 10
    /// ローカル信頼スコアの閾値
    static let localModeMinConfidence: Double = 0.6

    // MARK: - Public

    /// 提案を生成する（ハイブリッド判定）
    static func generateSuggestions(
        profile: UserInterestProfile,
        recentContents: [ScannedContent]
    ) async throws -> (suggestions: [Suggestion], usedLocalEngine: Bool) {

        let confidence = computeLocalConfidence(profile: profile)
        let useLocal = profile.totalScannedCount >= localModeMinScans
                    && confidence >= localModeMinConfidence

        if useLocal {
            let suggestions = generateLocally(profile: profile, recentContents: recentContents)
            return (suggestions, true)
        } else {
            let suggestions = try await ClaudeService.generateSuggestions(
                profile: profile,
                recentContents: recentContents
            )
            return (suggestions, false)
        }
    }

    // MARK: - ローカル信頼スコア

    /// プロファイルの蓄積度からローカルエンジンへの信頼スコアを計算
    /// - 興味ウェイトが揃っているほど高スコア
    static func computeLocalConfidence(profile: UserInterestProfile) -> Double {
        guard !profile.interestWeights.isEmpty else { return 0 }

        // 上位テーマのウェイト平均を信頼スコアとして使う
        let topWeights = profile.topInterests.prefix(3).map(\.weight)
        guard !topWeights.isEmpty else { return 0 }
        return topWeights.reduce(0, +) / Double(topWeights.count)
    }

    // MARK: - ローカル生成

    /// ユーザーの興味・キーワードをもとにローカルDBから提案を選出
    static func generateLocally(
        profile: UserInterestProfile,
        recentContents: [ScannedContent]
    ) -> [Suggestion] {

        let topCategories = Set(profile.topInterests.map(\.category))
        let recentKeywords = Set(recentContents.flatMap(\.keywords))
        let userGoalKeywords = extractKeywords(from: profile.idealGoals)

        // 各エントリをスコアリング
        let scored: [(entry: LocalSuggestionDatabase.Entry, score: Double)] =
            LocalSuggestionDatabase.entries.map { entry in
                var score = 0.0

                // カテゴリが上位興味と一致 → 高スコア
                if topCategories.contains(entry.category) {
                    score += profile.interestWeights[entry.category] ?? 0.3
                }

                // 最近のキーワードとの一致数
                let keywordMatches = entry.relatedKeywords.filter { recentKeywords.contains($0) }.count
                score += Double(keywordMatches) * 0.15

                // 目標キーワードとの一致
                let goalMatches = entry.relatedKeywords.filter { userGoalKeywords.contains($0) }.count
                score += Double(goalMatches) * 0.25

                return (entry, score)
            }

        // スコア順に並べ、タイプがバランスよくなるように5件選出
        let sorted = scored.sorted { $0.score > $1.score }
        let selected = selectBalanced(from: sorted, count: 5)

        return selected.map { entry in
            Suggestion(
                content: entry.content,
                type: entry.type,
                category: entry.category
            )
        }
    }

    // MARK: - Private

    /// quote/habit/action がバランスよく含まれるように選出
    private static func selectBalanced(
        from scored: [(entry: LocalSuggestionDatabase.Entry, score: Double)],
        count: Int
    ) -> [LocalSuggestionDatabase.Entry] {

        var result: [LocalSuggestionDatabase.Entry] = []
        var usedTypes: [SuggestionType: Int] = [.quote: 0, .habit: 0, .action: 0]
        let maxPerType = 2  // 各タイプ最大2件

        for item in scored {
            guard result.count < count else { break }
            let type = item.entry.type
            if (usedTypes[type] ?? 0) < maxPerType {
                result.append(item.entry)
                usedTypes[type, default: 0] += 1
            }
        }

        // 不足分はスコア順で補完
        if result.count < count {
            for item in scored where !result.contains(where: { $0.content == item.entry.content }) {
                result.append(item.entry)
                if result.count >= count { break }
            }
        }

        return result
    }

    /// 目標文字列からキーワードを簡易抽出
    private static func extractKeywords(from goals: [String]) -> Set<String> {
        let stopWords: Set<String> = ["する", "なる", "ため", "こと", "もの", "ます", "です", "して", "したい", "を", "に", "の", "が", "は"]
        let words = goals.joined(separator: " ")
            .components(separatedBy: CharacterSet.whitespaces.union(.punctuationCharacters))
            .filter { $0.count >= 2 && !stopWords.contains($0) }
        return Set(words)
    }
}
