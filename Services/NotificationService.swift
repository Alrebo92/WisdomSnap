import Foundation
import UserNotifications

struct NotificationService {

    // MARK: - 権限リクエスト

    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func currentAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - 毎朝通知のスケジュール

    /// 毎朝指定時刻に格言・習慣を通知する
    /// - Parameters:
    ///   - hour: 通知時刻（時）デフォルト8時
    ///   - minute: 通知時刻（分）デフォルト0分
    static func scheduleMorningNotification(hour: Int = 8, minute: Int = 0) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["morning-wisdom"])

        let content = UNMutableNotificationContent()
        content.title = "今日のひとこと"
        content.body = morningMessage()
        content.sound = .default
        content.badge = 1

        var dateComponents = DateComponents()
        dateComponents.hour   = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        let request = UNNotificationRequest(
            identifier: "morning-wisdom",
            content: content,
            trigger: trigger
        )
        center.add(request)
        WidgetDataService.isMorningNotificationEnabled = true
    }

    /// 通知をキャンセル
    static func cancelMorningNotification() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["morning-wisdom"])
        WidgetDataService.isMorningNotificationEnabled = false
    }

    /// 通知本文をローカルDBからランダムに選ぶ
    private static func morningMessage() -> String {
        LocalSuggestionDatabase.entries
            .filter { $0.type == .quote || $0.type == .habit }
            .randomElement()?
            .content
            ?? "今日も一歩、理想の自分へ。"
    }
}
