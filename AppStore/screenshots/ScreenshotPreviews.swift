import SwiftUI

/// AppStore用スクリーンショット撮影用プレビュー
/// Xcode Previews で各画面を表示してスクショを撮る
struct ScreenshotPreviews: View {
    var body: some View {
        TabView {
            screenshot1
            screenshot2
            screenshot3
            screenshot4
            screenshot5
        }
        .tabViewStyle(.page)
    }

    // 1枚目: キャッチコピー
    var screenshot1: some View {
        ZStack {
            LinearGradient(
                colors: [Color.accentColorColor, Color.accentColorColor.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()
                Image(systemName: "sparkles.rectangle.stack")
                    .font(.system(size: 80))
                    .foregroundStyle(.white)
                Text("スクショが、\nあなたを変える")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                Text("撮り溜めた格言・習慣スクショをAIが分析\nあなただけの成長プランを毎日提案")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.85))
                Spacer()
            }
            .padding()
        }
    }

    // 2枚目: スキャン機能
    var screenshot2: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack(spacing: 0) {
                Text("ライブラリ")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 2) {
                    ForEach(0..<9) { i in
                        ZStack(alignment: .bottomLeading) {
                            RoundedRectangle(cornerRadius: 0)
                                .fill(sampleColors[i % sampleColors.count].opacity(0.3))
                                .frame(height: 110)
                            Text(sampleThemes[i % sampleThemes.count])
                                .font(.caption2)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(.black.opacity(0.5))
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
            captionBanner(
                icon: "photo.on.rectangle.angled",
                title: "自動スキャン",
                body: "景色・食事はスキップ。格言・記事スクショだけを自動抽出"
            )
        }
    }

    // 3枚目: 提案カード
    var screenshot3: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack(alignment: .leading, spacing: 12) {
                Text("今日の提案")
                    .font(.largeTitle.bold())
                    .padding(.horizontal)
                    .padding(.top)
                ForEach(sampleSuggestions, id: \.0) { suggestion in
                    sampleCard(type: suggestion.1, content: suggestion.0, category: suggestion.2)
                }
                Spacer()
            }
            captionBanner(
                icon: "sparkles",
                title: "パーソナライズ提案",
                body: "あなたの興味・目標に合わせた格言・習慣・アクションを毎日5件"
            )
        }
    }

    // 4枚目: 興味マップ
    var screenshot4: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack(alignment: .leading, spacing: 16) {
                Text("あなたの分析")
                    .font(.largeTitle.bold())
                    .padding(.horizontal)
                    .padding(.top)
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(sampleInterests, id: \.0) { interest in
                        interestRow(category: interest.0, weight: interest.1)
                    }
                }
                .padding()
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)
                Spacer()
            }
            captionBanner(
                icon: "chart.bar.xaxis",
                title: "興味マップ",
                body: "スキャンを重ねるほど、あなたの価値観が可視化される"
            )
        }
    }

    // 5枚目: ウィジェット
    var screenshot5: some View {
        ZStack {
            LinearGradient(
                colors: [.black, Color(.systemGray6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()
                // ウィジェットモック
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("習慣")
                            .font(.caption2)
                    }
                    .foregroundStyle(.white.opacity(0.8))
                    Spacer()
                    Text("毎朝5分の瞑想があなたの一日を変える。静かな時間が創造性を生む。")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                }
                .padding(16)
                .frame(width: 160, height: 160)
                .background(LinearGradient(colors: [.accentColorColor, .accentColorColor.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .clipShape(RoundedRectangle(cornerRadius: 22))

                Text("ホーム画面ウィジェット対応")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text("毎朝新しい言葉があなたを出迎える")
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
            }
            .padding()
        }
    }

    // MARK: - Helper Views

    private func captionBanner(icon: String, title: String, body: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.accentColor)
                .frame(width: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(body).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
    }

    private func sampleCard(type: String, content: String, category: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(type).font(.caption).foregroundStyle(.secondary)
            Text(content).font(.subheadline)
            Text(category)
                .font(.caption)
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(Color.accentColorColor.opacity(0.12))
                .foregroundStyle(.accentColor)
                .clipShape(Capsule())
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
        .padding(.horizontal)
    }

    private func interestRow(category: String, weight: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(category).font(.subheadline)
                Spacer()
                Text("\(Int(weight * 100))%").font(.caption).foregroundStyle(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(.secondary.opacity(0.2)).frame(height: 8)
                    RoundedRectangle(cornerRadius: 4).fill(.accentColor).frame(width: geo.size.width * weight, height: 8)
                }
            }.frame(height: 8)
        }
    }

    // MARK: - Sample Data

    private let sampleColors: [Color] = [.blue, .purple, .green, .orange, .pink, .teal, .indigo, .red, .mint]
    private let sampleThemes = ["マインドセット", "習慣", "健康", "生産性", "学習"]
    private let sampleSuggestions: [(String, String, String)] = [
        ("失敗は成功への最短ルートだ。転んだ回数より、立ち上がった回数を数えよう。", "格言", "マインドセット"),
        ("毎朝5分の瞑想から始めよう。静かな時間が一日の質を変える。", "習慣", "健康"),
        ("今日読んだ内容を誰かに説明してみよう。理解度が格段に上がる。", "アクション", "学習"),
    ]
    private let sampleInterests: [(String, Double)] = [
        ("習慣", 0.88), ("マインドセット", 0.74), ("健康", 0.61), ("生産性", 0.45), ("学習", 0.38)
    ]
}

#Preview {
    ScreenshotPreviews()
}
