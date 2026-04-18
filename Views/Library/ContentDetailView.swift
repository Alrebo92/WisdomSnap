import SwiftUI

struct ContentDetailView: View {
    let content: ScannedContent

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let data = content.thumbnailData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("抽出テキスト")
                        .font(.headline)
                    Text(content.extractedText.isEmpty ? "（テキストなし）" : content.extractedText)
                        .font(.body)
                        .foregroundStyle(content.extractedText.isEmpty ? .secondary : .primary)
                }

                if !content.themes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("テーマ")
                            .font(.headline)
                        TagFlowView(tags: content.themes, color: Color.accentColor)
                    }
                }

                if !content.keywords.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("キーワード")
                            .font(.headline)
                        TagFlowView(tags: content.keywords, color: .secondary)
                    }
                }

                Text("スキャン日時: \(content.processedDate.formatted(.dateTime.year().month().day().hour().minute()))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("詳細")
        .navigationBarTitleDisplayMode(.inline)
    }
}
