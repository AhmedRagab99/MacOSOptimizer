//
//  TrashView.swift
//  MacAppOptimizer
//
//  Created by Ahmed Ragab on 09/02/2025.
//

import SwiftUI

struct TrashItem: Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    let size: UInt64
}

class TrashViewModel: ObservableObject {
    @Published var trashItems: [TrashItem] = []
    @Published var selectedItems: Set<UUID> = []
    @Published var deletionProgress: Double = 0.0
    @Published var isDeleting: Bool = false

    init() {
        fetchTrashItems()
    }

    // Fetch items from the Trash directory
    func fetchTrashItems() {
        trashItems.removeAll()
        let trashURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".Trash")

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: trashURL, includingPropertiesForKeys: [.fileSizeKey], options: .skipsHiddenFiles)

            for fileURL in fileURLs {
                let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                let fileSize = resourceValues.fileSize ?? 0

                let item = TrashItem(url: fileURL, name: fileURL.lastPathComponent, size: UInt64(fileSize))
                trashItems.append(item)
            }
        } catch {
            print("Error fetching trash items: \(error.localizedDescription)")
        }
    }

    // Calculate total size of selected items
    func totalSelectedSize() -> UInt64 {
        trashItems
            .filter { selectedItems.contains($0.id) }
            .reduce(0) { $0 + $1.size }
    }

    // Permanently delete selected items with progress tracking
    func deleteSelectedItems() {
        let itemsToDelete = trashItems.filter { selectedItems.contains($0.id) }
        let totalItems = itemsToDelete.count

        guard totalItems > 0 else { return }

        isDeleting = true
        deletionProgress = 0.0

        DispatchQueue.global(qos: .background).async {
            for (index, item) in itemsToDelete.enumerated() {
                do {
                    try FileManager.default.removeItem(at: item.url)
                } catch {
                    print("Error deleting \(item.name): \(error.localizedDescription)")
                }
                
                DispatchQueue.main.async {
                    self.deletionProgress = Double(index + 1) / Double(totalItems)
                }
            }
            
            DispatchQueue.main.async {
                self.isDeleting = false
                self.fetchTrashItems()
                self.selectedItems.removeAll()
            }
        }
    }
}

struct TrashView: View {
    @StateObject private var viewModel = TrashViewModel()

    var body: some View {
        VStack {
            List(selection: $viewModel.selectedItems) {
                ForEach(viewModel.trashItems) { item in
                    HStack {
                        Image(systemName: "doc.fill")
                            .foregroundColor(.gray)
                            .frame(width: 20)

                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            Text("\(formatSize(item.size))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                        Text(item.url.path)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    .tag(item.id)
                }
            }
            .frame(minHeight: 400)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        viewModel.deleteSelectedItems()
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                    .disabled(viewModel.selectedItems.isEmpty || viewModel.isDeleting)
                }
            }

            if viewModel.isDeleting {
                ProgressView("Deleting...", value: viewModel.deletionProgress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding()
            }

            HStack {
                Text("Total Size of Selected Items:")
                    .font(.subheadline)
                Spacer()
                Text("\(formatSize(viewModel.totalSelectedSize()))")
                    .font(.headline)
            }
            .padding()
        }
        .padding()
        .navigationTitle("Trash")
    }
}

// Helper function to format file size in a readable format
func formatSize(_ bytes: UInt64) -> String {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useMB, .useGB]
    formatter.countStyle = .file
    return formatter.string(fromByteCount: Int64(bytes))
}
