//
//  JunkFile.swift
//  MacAppOptimizer
//
//  Created by Ahmed Ragab on 03/02/2025.
//



import SwiftUI
//
struct JunkFile: Identifiable {
    let id = UUID()
    let url: URL
    let size: UInt64
    var isSelected: Bool = false
}


actor JunkFileManager {
    private var junkFiles: [URL] = []

    func addJunkFile(_ fileURL: URL) {
        junkFiles.append(fileURL)
    }

    func getJunkFiles() -> [URL] {
        return junkFiles
    }

    func clearJunkFiles() {
        junkFiles.removeAll()
    }
}

struct JunkFileCleanupView: View {
    @State private var junkFiles: [JunkFile] = []
    @State private var isScanning: Bool = false
    @State private var junkFilesCount: Int = 0
    @State private var progress: Double = 0.0
    @State private var isPermissionDenied: Bool = false
    @State private var permissionDeniedFor: PermissionType?

    var body: some View {
        VStack {
            Text("Junk File Cleanup").font(.title2).bold()
            
            Text("Junk files found: \(junkFilesCount)")

            if isScanning {
                ProgressView("Scanning...", value: progress, total: Double(junkFilesCount))
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding()
            }

            Button("Scan for Junk Files") {
                if PermissionManager.shared.isPermissionGranted(.fullDiskAccess) {
                    Task {
                        await scanForJunkFiles()
                    }
                } else {
                    permissionDeniedFor = .fullDiskAccess
                    isPermissionDenied = true
                }
            }
            .buttonStyle(.bordered)

            List {
                ForEach($junkFiles) { $junkFile in
                    HStack {
                        Toggle(isOn: $junkFile.isSelected) {
                            Text(junkFile.url.lastPathComponent)
                                .font(.subheadline)
                        }
                        
                        Spacer()

                        Text("\(formattedSize(junkFile.size))")
                            .font(.subheadline)
                    }
                }
            }

            Button("Delete Junk Files") {
                Task {
                    await deleteSelectedJunkFiles()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(junkFiles.isEmpty)
            
            Spacer()
        }
        .padding()
        .alert(isPresented: $isPermissionDenied) {
            PermissionManager.shared.showPermissionDeniedAlert(permission: permissionDeniedFor!)
        }
    }

    func deleteSelectedJunkFiles() async {
        let fileManager = FileManager.default
        for junkFile in junkFiles where junkFile.isSelected {
            do {
                try fileManager.removeItem(at: junkFile.url)
            } catch {
                print("Failed to delete file: \(error.localizedDescription)")
            }
        }
    }
    
    func scanForJunkFiles() async {
        isScanning = true
        
        // Call async function to find junk files
        let foundJunkFiles = await findJunkFilesAndFolders()
        
        // Now update UI on the main thread
        await MainActor.run {
            self.junkFiles = foundJunkFiles.map { JunkFile(url: $0, size: fileSize(at: $0)) }
            self.junkFilesCount = self.junkFiles.count
            self.progress = 1.0
            self.isScanning = false
        }
    }

    func findJunkFilesAndFolders() async -> [URL] {
        let fileManager = FileManager.default
        let junkFileManager = JunkFileManager()

        // Define common cache directories
        let cacheDirectories = [
//            fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first?.appendingPathComponent("Caches"),
//            fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first?.appendingPathComponent("Logs"),
//            fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first?.appendingPathComponent("Saved Application State"),
//            fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first?.appendingPathComponent("Containers"),
            fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first?.appendingPathComponent("Developer/Xcode/DerivedData"),
//            fileManager.urls(for: .developerDirectory, in: .userDomainMask).first?.appendingPathComponent("Xcode/Archives"),
//            fileManager.urls(for: .developerDirectory, in: .userDomainMask).first?.appendingPathComponent("Xcode/iOS DeviceSupport"),
//            fileManager.urls(for: .developerDirectory, in: .userDomainMask).first?.appendingPathComponent("Xcode/watchOS DeviceSupport"),
//            fileManager.urls(for: .developerDirectory, in: .userDomainMask).first?.appendingPathComponent("Xcode/tvOS DeviceSupport")
        ].compactMap { $0 }

        // Process directories asynchronously
        await withTaskGroup(of: Void.self) { group in
            for directory in cacheDirectories {
                group.addTask {
                    await processDirectory(directory, fileManager: fileManager, junkFileManager: junkFileManager)
                }
            }
        }

        // Return the collected junk files
        return await junkFileManager.getJunkFiles()
    }
    
    func processDirectory(_ directory: URL, fileManager: FileManager, junkFileManager: JunkFileManager) async {
        // Enumerate files in the directory asynchronously
        guard let enumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) else { return }
        
        for case let fileURL as URL in enumerator {
            do {
                // Check if file size is greater than 0 and only then add it
                let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
                if let fileSize = attributes[.size] as? NSNumber, fileSize.intValue > 0 {
                    await junkFileManager.addJunkFile(fileURL)
                }
            } catch {
                // Handle error (e.g., permissions issue) if necessary
                print("Failed to get attributes for file: \(fileURL), error: \(error)")
            }
        }
    }

    func fileSize(at url: URL) -> UInt64 {
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        return attributes?[.size] as? UInt64 ?? 0
    }

    func formattedSize(_ size: UInt64) -> String {
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [.useKB, .useMB, .useGB]
        byteCountFormatter.countStyle = .file
        return byteCountFormatter.string(fromByteCount: Int64(size))
    }
}
