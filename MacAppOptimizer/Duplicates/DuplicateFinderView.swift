//
//  DuplicateFinderView.swift
//  MacAppOptimizer
//
//  Created by Ahmed Ragab on 03/02/2025.
//


import SwiftUI
import CryptoKit

struct DuplicateFinderView: View {
    @State private var duplicateCount: Int = 0

    var body: some View {
        VStack {
            Text("Duplicate Finder").font(.title2).bold()

            Text("Duplicate files found: \(duplicateCount)")

            Button("Scan for Duplicates") {
                duplicateCount = findDuplicateFiles(in: FileManager.default.homeDirectoryForCurrentUser).count
            }
            .buttonStyle(.bordered)

            Button("Delete Duplicates") {
                deleteDuplicateFiles()
                duplicateCount = 0
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
    }
    /// Calculates the SHA256 hash for a given file URL.
    func getFileHash(fileURL: URL) -> String {
        let fileData = try? Data(contentsOf: fileURL)
        if let data = fileData {
            let hash = SHA256.hash(data: data)
            return hash.compactMap { String(format: "%02x", $0) }.joined()  // Convert hash to hex string
        }
        return ""
    }
    func deleteDuplicateFiles() {
        let duplicates = findDuplicateFiles(in: FileManager.default.homeDirectoryForCurrentUser)
        
        // For each duplicate group, delete all but the first file
        for group in duplicates {
            for url in group.dropFirst() {
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    print("Error deleting duplicate file: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func findDuplicateFiles(in directory: URL) -> [[URL]] {
        let fileManager = FileManager.default
        var duplicateGroups: [[URL]] = []
        
        do {
            // Get all file URLs in the directory
            let fileURLs = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            
            var fileHashes: [String: [URL]] = [:]
            
            // For each file, calculate its hash and group them by matching hash
            for fileURL in fileURLs {
                let hash = getFileHash(fileURL: fileURL)
                if var group = fileHashes[hash] {
                    group.append(fileURL)
                    fileHashes[hash] = group
                } else {
                    fileHashes[hash] = [fileURL]
                }
            }
            
            // Include only groups with more than one file (duplicates)
            for group in fileHashes.values {
                if group.count > 1 {
                    duplicateGroups.append(group)
                }
            }
        } catch {
            print("Error finding duplicates: \(error.localizedDescription)")
        }
        
        return duplicateGroups
    }
}

#Preview {
    DuplicateFinderView()

}
