import Foundation

enum ClaudeServiceError: LocalizedError {
    case invalidAPIKey
    case networkError(Error)
    case invalidResponse
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:   return "APIキーが設定されていません"
        case .networkError(let e): return "通信エラー: \(e.localizedDescription)"
        case .invalidResponse: return "サーバーからの応答が不正です"
        case .decodingError:   return "データの解析に失敗しました"
        }
    }
}

class ClaudeService {

    private static let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!
    private static let model    = "claude-3-5-haiku-20241022"

    // MARK: - テキスト分析

    /// OCR テキストからテーマとキーワードを抽出
    static func analyzeContent(_ text: String) async throws -> (themes: [String], keywords: [String]) {
        let prompt = """
        以下は画像から抽出されたテキストです。自己啓発・格言・習慣・マインドセット等に関する内容を分析し、以下のJSON形式で返してください。
        関係のない内容（レシートや住所等）の場合は空配列を返してください。

        テキスト:
        \(text)

        返答形式（このJSONのみ返す。説明文は不要）:
        {
          "themes": ["テーマ1", "テーマ2"],
          "keywords": ["キーワード1", "キーワード2", "キーワード3"]
        }

        themeの候補: マインドセット, 習慣, 健康, 生産性, 人間関係, 読書, 学習, 成功, メンタル, キャリア, お金, 創造性
        keywordsは3〜6個の重要語を抽出してください。
        """

        let response = try await sendMessage(prompt)
        return try parseAnalysisResponse(response)
    }

    // MARK: - 提案生成

    /// ユーザープロファイルをもとにパーソナライズされた提案を生成
    static func generateSuggestions(
        profile: UserInterestProfile,
        recentContents: [ScannedContent]
    ) async throws -> [Suggestion] {

        let topInterests = profile.topInterests
            .map { "\($0.category)（関心度: \(Int($0.weight * 100))%）" }
            .joined(separator: ", ")

        let goals = profile.idealGoals.isEmpty
            ? "未設定"
            : profile.idealGoals.joined(separator: "、")

        let recentTexts = recentContents.prefix(10)
            .map { "・\($0.extractedText.prefix(100))" }
            .joined(separator: "\n")

        let prompt = """
        以下はユーザーの興味・目標・最近読んだ格言や習慣の情報です。
        この人に最適な格言・習慣・アクションを合計5件提案してください。

        【ユーザー情報】
        目標: \(goals)
        主な関心: \(topInterests.isEmpty ? "まだ分析中" : topInterests)

        【最近スキャンした内容（抜粋）】
        \(recentTexts.isEmpty ? "まだスキャンデータがありません" : recentTexts)

        返答形式（このJSONのみ。説明文不要）:
        {
          "suggestions": [
            {
              "content": "提案内容",
              "type": "quote | habit | action",
              "category": "カテゴリ名"
            }
          ]
        }

        typeの意味: quote=格言・名言, habit=毎日続ける習慣, action=今すぐできるアクション
        categoryはユーザーの関心テーマから選んでください。
        提案はユーザーの目標・関心に直結した具体的な内容にしてください。
        """

        let response = try await sendMessage(prompt)
        return try parseSuggestionsResponse(response)
    }

    // MARK: - プロファイル更新

    /// スキャン結果をもとにユーザーの興味ウェイトを更新
    static func updateInterestProfile(
        profile: UserInterestProfile,
        newContents: [ScannedContent]
    ) {
        var weights = profile.interestWeights
        let allThemes = newContents.flatMap(\.themes)

        for theme in allThemes {
            let current = weights[theme] ?? 0.0
            // 指数移動平均でなめらかに更新
            weights[theme] = current * 0.85 + 0.15
        }

        // 未登場テーマは少し減衰
        for key in weights.keys where !allThemes.contains(key) {
            weights[key] = (weights[key] ?? 0) * 0.95
        }

        profile.interestWeights = weights
        profile.totalScannedCount += newContents.count
        profile.updatedDate = .now
    }

    // MARK: - HTTP

    private static func sendMessage(_ prompt: String) async throws -> String {
        guard !Secrets.claudeAPIKey.isEmpty,
              Secrets.claudeAPIKey != "YOUR_API_KEY_HERE" else {
            throw ClaudeServiceError.invalidAPIKey
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json",      forHTTPHeaderField: "Content-Type")
        request.setValue(Secrets.claudeAPIKey,    forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01",            forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": model,
            "max_tokens": 1024,
            "messages": [["role": "user", "content": prompt]]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw ClaudeServiceError.networkError(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw ClaudeServiceError.invalidResponse
        }
        guard http.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw ClaudeServiceError.networkError(
                NSError(domain: "ClaudeAPI", code: http.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body.prefix(200))"])
            )
        }

        // レスポンスから text を取り出す
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let content = (json["content"] as? [[String: Any]])?.first,
            let text = content["text"] as? String
        else {
            throw ClaudeServiceError.decodingError
        }

        return text
    }

    // MARK: - パース

    private static func parseAnalysisResponse(
        _ text: String
    ) throws -> (themes: [String], keywords: [String]) {

        guard let data = extractJSON(from: text),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ClaudeServiceError.decodingError
        }

        let themes   = json["themes"]   as? [String] ?? []
        let keywords = json["keywords"] as? [String] ?? []
        return (themes, keywords)
    }

    private static func parseSuggestionsResponse(_ text: String) throws -> [Suggestion] {
        guard let data = extractJSON(from: text),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let items = json["suggestions"] as? [[String: Any]] else {
            throw ClaudeServiceError.decodingError
        }

        return items.compactMap { item -> Suggestion? in
            guard
                let content  = item["content"]  as? String,
                let typeStr  = item["type"]      as? String,
                let category = item["category"]  as? String
            else { return nil }

            let type: SuggestionType = switch typeStr {
                case "habit":  .habit
                case "action": .action
                default:       .quote
            }
            return Suggestion(content: content, type: type, category: category)
        }
    }

    /// レスポンス文字列からJSONブロックを抽出する
    private static func extractJSON(from text: String) -> Data? {
        // ```json ... ``` または { ... } を探す
        let stripped = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```",     with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let start = stripped.range(of: "{"),
              let end   = stripped.range(of: "}", options: .backwards) else {
            return nil
        }
        let jsonString = String(stripped[start.lowerBound...end.upperBound])
        return jsonString.data(using: .utf8)
    }
}
