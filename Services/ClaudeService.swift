import Foundation

/// Phase C で実装予定
/// Claude API を使ってテキスト分析・提案生成を行う
class ClaudeService {

    private static let apiKey = ""  // Phase C: Secrets管理に切り替える
    private static let model  = "claude-haiku-4-5-20251001"  // コスト最適化

    /// テキストのテーマとキーワードを分析
    /// - Parameter text: OCR で抽出したテキスト
    /// - Returns: テーマ配列とキーワード配列
    static func analyzeContent(_ text: String) async throws -> (themes: [String], keywords: [String]) {
        // Phase C で実装
        // プロンプト例:
        // "以下のテキストから自己啓発・習慣・マインドセット等のテーマと
        //  重要キーワードをJSON形式で抽出してください: \(text)"
        return (themes: [], keywords: [])
    }

    /// ユーザープロファイルをもとに提案を生成
    /// - Parameters:
    ///   - profile: ユーザーの興味・目標プロファイル
    ///   - recentContents: 最近スキャンした内容
    /// - Returns: パーソナライズされた提案リスト
    static func generateSuggestions(
        profile: UserInterestProfile,
        recentContents: [ScannedContent]
    ) async throws -> [Suggestion] {
        // Phase C で実装
        // 初期はClaude API、蓄積後はローカルルール+APIのハイブリッドへ
        return []
    }
}
