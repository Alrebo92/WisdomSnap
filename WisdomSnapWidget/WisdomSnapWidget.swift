import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Timeline Entry

struct WisdomEntry: TimelineEntry {
    let date: Date
    let content: String
    let type: String
    let category: String
}

// MARK: - Provider

struct WisdomProvider: TimelineProvider {

    func placeholder(in context: Context) -> WisdomEntry {
        WisdomEntry(
            date: .now,
            content: "小さな習慣の積み重ねが、大きな変化を生む。",
            type: "習慣",
            category: "習慣"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WisdomEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WisdomEntry>) -> Void) {
        let entry = loadEntry()
        // 毎朝8時に更新
        let nextUpdate = Calendar.current.nextDate(
            after: .now,
            matching: DateComponents(hour: 8, minute: 0),
            matchingPolicy: .nextTime
        ) ?? Date().addingTimeInterval(3600 * 8)

        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadEntry() -> WisdomEntry {
        // App Group 経由でメインアプリのデータを読み込む
        if let data = UserDefaults(suiteName: "group.com.alrebo92.WisdomSnap")?.data(forKey: "todaySuggestion"),
           let suggestion = try? JSONDecoder().decode(WidgetSuggestion.self, from: data) {
            return WisdomEntry(
                date: .now,
                content: suggestion.content,
                type: suggestion.type,
                category: suggestion.category
            )
        }
        // フォールバック: ローカルDBからランダムに選ぶ
        let fallback = LocalSuggestionDatabase.entries.randomElement()
        return WisdomEntry(
            date: .now,
            content: fallback?.content ?? "今日も一歩、理想の自分へ。",
            type: fallback?.type.rawValue ?? "格言",
            category: fallback?.category ?? "マインドセット"
        )
    }
}

// MARK: - Widget Views

struct WisdomWidgetSmallView: View {
    let entry: WisdomEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.caption)
                Text(entry.category)
                    .font(.caption2)
            }
            .foregroundStyle(.white.opacity(0.8))

            Spacer()

            Text(entry.content)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .lineLimit(4)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(gradient)
    }

    private var gradient: LinearGradient {
        LinearGradient(
            colors: [Color.accentColorColor, Color.accentColorColor.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct WisdomWidgetMediumView: View {
    let entry: WisdomEntry

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: typeIcon)
                .font(.system(size: 36))
                .foregroundStyle(.white.opacity(0.9))
                .frame(width: 50)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(entry.type)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(.white.opacity(0.2))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                    Text(entry.category)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.7))
                }
                Text(entry.content)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .lineLimit(3)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(gradient)
    }

    private var typeIcon: String {
        switch entry.type {
        case "習慣":  return "repeat.circle.fill"
        case "アクション": return "checkmark.circle.fill"
        default: return "quote.bubble.fill"
        }
    }

    private var gradient: LinearGradient {
        LinearGradient(
            colors: [Color.accentColorColor, Color.accentColorColor.opacity(0.6)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Widget Definition

struct WisdomSnapWidget: Widget {
    let kind = "WisdomSnapWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WisdomProvider()) { entry in
            WisdomWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("今日の格言・習慣")
        .description("あなたの興味・目標に合わせた格言や習慣を毎日表示します。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct WisdomWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: WisdomEntry

    var body: some View {
        switch family {
        case .systemSmall:
            WisdomWidgetSmallView(entry: entry)
        default:
            WisdomWidgetMediumView(entry: entry)
        }
    }
}
