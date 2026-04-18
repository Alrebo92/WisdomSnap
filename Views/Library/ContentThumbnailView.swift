import SwiftUI

struct ContentThumbnailView: View {
    let content: ScannedContent

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let data = content.thumbnailData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(.secondary.opacity(0.15))
                    .overlay {
                        Image(systemName: content.isScreenshot ? "iphone" : "doc.text")
                            .foregroundStyle(.secondary)
                    }
            }

            if let theme = content.themes.first {
                Text(theme)
                    .font(.caption2)
                    .lineLimit(1)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(.black.opacity(0.6))
                    .foregroundStyle(.white)
            }
        }
        .frame(height: 120)
        .clipped()
    }
}
