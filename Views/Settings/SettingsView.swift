import SwiftUI
import UserNotifications

struct SettingsView: View {
    @State private var notificationEnabled = false
    @State private var notificationHour    = 8
    @State private var notificationMinute  = 0
    @State private var authStatus: UNAuthorizationStatus = .notDetermined
    @State private var showPermissionAlert = false

    var body: some View {
        NavigationStack {
            Form {
                notificationSection
                widgetSection
                aboutSection
            }
            .navigationTitle("設定")
            .onAppear { loadSettings() }
            .alert("通知の許可が必要です", isPresented: $showPermissionAlert) {
                Button("設定を開く") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("「設定 > WisdomSnap > 通知」から許可してください")
            }
        }
    }

    // MARK: - セクション

    private var notificationSection: some View {
        Section {
            Toggle("毎朝の格言通知", isOn: $notificationEnabled)
                .onChange(of: notificationEnabled) { _, newValue in
                    Task { await toggleNotification(newValue) }
                }

            if notificationEnabled {
                HStack {
                    Text("通知時刻")
                    Spacer()
                    Picker("時", selection: $notificationHour) {
                        ForEach(4..<12, id: \.self) { h in
                            Text("\(h)時").tag(h)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80, height: 80)
                    .clipped()

                    Picker("分", selection: $notificationMinute) {
                        ForEach([0, 15, 30, 45], id: \.self) { m in
                            Text("\(String(format: "%02d", m))分").tag(m)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80, height: 80)
                    .clipped()
                }
                .onChange(of: notificationHour)   { _, _ in reschedule() }
                .onChange(of: notificationMinute) { _, _ in reschedule() }
            }
        } header: {
            Text("通知")
        } footer: {
            Text("毎朝、あなたの興味・目標に合った格言や習慣をお届けします。")
        }
    }

    private var widgetSection: some View {
        Section("ウィジェット") {
            HStack {
                Image(systemName: "rectangle.3.group")
                    .foregroundStyle(.accent)
                Text("ホーム画面に追加する方法")
            }
            Text("ホーム画面を長押し → 「+」ボタン → WisdomSnap を検索して追加")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var aboutSection: some View {
        Section("このアプリについて") {
            LabeledContent("バージョン", value: "1.0.0")
        }
    }

    // MARK: - ロジック

    private func loadSettings() {
        notificationEnabled = WidgetDataService.isMorningNotificationEnabled
        Task {
            authStatus = await NotificationService.currentAuthorizationStatus()
        }
    }

    private func toggleNotification(_ enabled: Bool) async {
        if enabled {
            // 権限確認
            let status = await NotificationService.currentAuthorizationStatus()
            if status == .denied {
                await MainActor.run { showPermissionAlert = true; notificationEnabled = false }
                return
            }
            if status == .notDetermined {
                let granted = await NotificationService.requestAuthorization()
                if !granted {
                    await MainActor.run { notificationEnabled = false }
                    return
                }
            }
            NotificationService.scheduleMorningNotification(
                hour: notificationHour,
                minute: notificationMinute
            )
        } else {
            NotificationService.cancelMorningNotification()
        }
    }

    private func reschedule() {
        guard notificationEnabled else { return }
        NotificationService.scheduleMorningNotification(
            hour: notificationHour,
            minute: notificationMinute
        )
    }
}
