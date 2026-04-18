import Foundation
import WidgetKit

/// メインアプリ → ウィジェットへデータを渡すサービス
struct WidgetDataService {

    private static let appGroupID    = "group.com.alrebo92.WisdomSnap"
    private static let suggestionKey = "todaySuggestion"
    private static let notificationKey = "morningNotificationEnabled"

    // MARK: - ウィジェット用データ更新

    /// 今日の提案をApp Groupに保存してウィジェットをリロード
    static func updateTodaySuggestion(_ suggestion: Suggestion) {
        let widget = WidgetSuggestion(
            content: suggestion.content,
            type: suggestion.type.rawValue,
            category: suggestion.category
        )
        guard let data = try? JSONEncoder().encode(widget),
              let defaults = UserDefaults(suiteName: appGroupID) else { return }

        defaults.set(data, forKey: suggestionKey)
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - 通知設定

    static var isMorningNotificationEnabled: Bool {
        get { UserDefaults(suiteName: appGroupID)?.bool(forKey: notificationKey) ?? false }
        set { UserDefaults(suiteName: appGroupID)?.set(newValue, forKey: notificationKey) }
    }
}
