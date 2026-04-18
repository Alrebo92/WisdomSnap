import Foundation

/// ウィジェットとメインアプリ間で共有するデータ構造
/// App Group (UserDefaults) 経由で受け渡す
struct WidgetSuggestion: Codable {
    let content: String
    let type: String
    let category: String
}
