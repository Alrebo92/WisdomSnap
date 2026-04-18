import SwiftUI

/// タグをフロー状に折り返して表示するコンポーネント
struct TagFlowView: View {
    let tags: [String]
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            generateContent(in: geometry)
        }
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(tags, id: \.self) { tag in
                tagView(tag)
                    .padding(.trailing, 6)
                    .padding(.bottom, 6)
                    .alignmentGuide(.leading) { dimension in
                        if abs(width - dimension.width) > geometry.size.width {
                            width = 0
                            height -= dimension.height + 6
                        }
                        let result = width
                        if tag == tags.last { width = 0 }
                        else { width -= dimension.width + 6 }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if tag == tags.last { height = 0 }
                        return result
                    }
            }
        }
    }

    private func tagView(_ tag: String) -> some View {
        Text(tag)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.12))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}
