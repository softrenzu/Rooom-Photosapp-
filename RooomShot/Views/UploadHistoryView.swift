import SwiftUI

struct UploadHistoryView: View {
    @EnvironmentObject private var uploads: UploadQueue

    var body: some View {
        NavigationStack {
            Group {
                if uploads.items.isEmpty {
                    ContentUnavailableView(
                        "history.empty.title",
                        systemImage: "photo.stack",
                        description: Text("history.empty.body")
                    )
                } else {
                    List {
                        ForEach(uploads.items) { item in
                            historyRow(item)
                                .listRowBackground(Color.white.opacity(0.055))
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(BrandBackground())
                }
            }
            .navigationTitle("history.title")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("history.retryAll", systemImage: "arrow.clockwise") {
                            uploads.retryAll()
                        }
                        Button(role: .destructive) {
                            uploads.clearCompleted()
                        } label: {
                            Label("history.clearCompleted", systemImage: "checkmark.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }

    private func historyRow(_ item: UploadItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.fileName)
                        .font(.subheadline.monospaced())
                        .lineLimit(1)
                    Text(item.createdAt, format: .dateTime.year().month().day().hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                UploadStatusBadge(status: item.status)
            }

            if let error = item.errorMessage, item.status == .failed {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .lineLimit(2)
                Button("history.retry") { uploads.retry(item.id) }
                    .font(.caption.weight(.semibold))
            }
        }
        .padding(.vertical, 7)
    }
}
