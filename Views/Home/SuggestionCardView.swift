import SwiftUI

struct SuggestionCardView: View {
    let suggestion: Suggestion
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(suggestion.type.rawValue, systemImage: typeIcon)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    suggestion.isBookmarked.toggle()
                    try? modelContext.save()
                } label: {
                    Image(systemName: suggestion.isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(suggestion.isBookmarked ? Color.accentColor : .secondary)
                }
                .buttonStyle(.plain)
            }

            Text(suggestion.content)
                .font(.body)

            Text(suggestion.category)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.accentColor.opacity(0.12))
                .foregroundStyle(Color.accentColor)
                .clipShape(Capsule())
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }

    private var typeIcon: String {
        switch suggestion.type {
        case .quote:  return "quote.bubble"
        case .habit:  return "repeat.circle"
        case .action: return "checkmark.circle"
        }
    }
}
