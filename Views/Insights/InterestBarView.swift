import SwiftUI

struct InterestBarView: View {
    let category: String
    let weight: Double  // 0.0 〜 1.0

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(category)
                    .font(.subheadline)
                Spacer()
                Text("\(Int(weight * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.secondary.opacity(0.2))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.accentColor)
                        .frame(width: geo.size.width * weight, height: 8)
                        .animation(.easeOut, value: weight)
                }
            }
            .frame(height: 8)
        }
    }
}
