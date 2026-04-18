import SwiftUI
import SwiftData

struct LibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ScannedContent.processedDate, order: .reverse) private var contents: [ScannedContent]
    @State private var viewModel = LibraryViewModel()

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            Group {
                if contents.isEmpty {
                    emptyState
                } else {
                    contentGrid
                }
            }
            .navigationTitle("ライブラリ")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.startScan(modelContext: modelContext)
                    } label: {
                        Label("スキャン", systemImage: "arrow.clockwise")
                    }
                    .disabled(viewModel.isScanning)
                }
            }
            .overlay {
                if viewModel.isScanning {
                    ProgressView("スキャン中...")
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("スキャンするとスクショから\nテキストを読み取ります")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("スキャン開始") {
                viewModel.startScan(modelContext: modelContext)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var contentGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(contents) { content in
                    NavigationLink {
                        ContentDetailView(content: content)
                    } label: {
                        ContentThumbnailView(content: content)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
