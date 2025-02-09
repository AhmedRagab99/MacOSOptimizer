//
//  FileItem.swift
//  MacAppOptimizer
//
//  Created by Ahmed Ragab on 03/02/2025.
//



import Foundation
import SwiftUI

/// Represents a file or folder with metadata
struct FileItems: Identifiable,Hashable {
    let id = UUID()
    let name: String           // File name
    let path: String           // Full path
    let size: String           // Formatted size
    let isDirectory: Bool      // Folder or file
}

/// Fetches all files & folders in a given directory.
/// - Parameter directoryPath: The path to list files from.
/// - Returns: An array of `FileItems` representing files & folders.
func getFilesInDirectory(directoryPath: String) -> [FileItems] {
    let fileManager = FileManager.default
    var fileList: [FileItems] = []

    do {
        let items = try fileManager.contentsOfDirectory(atPath: directoryPath)
        
        for item in items {
            let fullPath = (directoryPath as NSString).appendingPathComponent(item)
            var isDirectory: ObjCBool = false
            
            if fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory) {
                let size = isDirectory.boolValue ? getFolderSize(path: fullPath) : getFileSize(path: fullPath)
                let file = FileItems(name: item, path: fullPath, size: size, isDirectory: isDirectory.boolValue)
                fileList.append(file)
            }
        }
    } catch {
        print("❌ Error fetching files: \(error)")
    }
    
    return fileList
}

/// Calculates **file size in MB**.
/// - Parameter path: File path.
/// - Returns: Formatted size string (e.g., "2.4 MB").
func getFileSize(path: String) -> String {
    let fileManager = FileManager.default
    do {
        let attributes = try fileManager.attributesOfItem(atPath: path)
        if let fileSize = attributes[.size] as? UInt64 {
            let sizeMB = Double(fileSize) / (1024 * 1024) // Convert to MB
            return String(format: "%.2f MB", sizeMB)
        }
    } catch {
        print("❌ Error getting file size: \(error)")
    }
    return "0 MB"
}

/// Calculates **folder size recursively**.
/// - Parameter path: Folder path.
/// - Returns: Formatted size string (e.g., "12.5 MB").
func getFolderSize(path: String) -> String {
    let fileManager = FileManager.default
    var totalSize: UInt64 = 0

    do {
        let contents = try fileManager.subpathsOfDirectory(atPath: path)
        for content in contents {
            let fullPath = (path as NSString).appendingPathComponent(content)
            let attributes = try fileManager.attributesOfItem(atPath: fullPath)
            if let fileSize = attributes[.size] as? UInt64 {
                totalSize += fileSize
            }
        }
    } catch {
        print("❌ Error calculating folder size: \(error)")
    }

    let sizeMB = Double(totalSize) / (1024 * 1024) // Convert to MB
    return String(format: "%.2f MB", sizeMB)
}

/// Main view displaying a list of files and folders.
struct FileListView: View {
    let directoryPath: String
    @State private var files: [FileItems] = []
    @State private var selectedFile: FileItems?  // Selected file or folder

    var body: some View {
        NavigationSplitView {
            List(files, selection: $selectedFile) { file in
                NavigationLink(destination: destinationView(for: file)) {
                    HStack {
                        Image(systemName: file.isDirectory ? "folder.fill" : "doc.fill")
                            .foregroundColor(file.isDirectory ? .blue : .gray)
                        VStack(alignment: .leading) {
                            Text(file.name)
                                .font(.headline)
                            Text(file.size)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                }
            }
            .navigationTitle(directoryPath.components(separatedBy: "/").last ?? "Files")
            .onAppear {
                files = getFilesInDirectory(directoryPath: directoryPath)
            }
        } detail: {
            if let selectedFile = selectedFile {
                destinationView(for: selectedFile)
            } else {
                Text("Select a file or folder").foregroundColor(.gray)
            }
        }
    }

    /// Determines whether to open a folder view or a file detail view.
    private func destinationView(for file: FileItems) -> some View {
        if file.isDirectory {
            return AnyView(FileDetailListView(directoryPath: file.path, folderName: file.name))
        } else {
            return AnyView(FileDetailView(file: file))
        }
    }
}


/// Shows the list of files inside a selected folder.
struct FileDetailListView: View {
    let directoryPath: String
    let folderName: String
    @State private var files: [FileItems] = []

    var body: some View {
        List(files) { file in
            NavigationLink(destination: destinationView(for: file)) {
                HStack {
                    Image(systemName: file.isDirectory ? "folder.fill" : "doc.fill")
                        .foregroundColor(file.isDirectory ? .blue : .gray)
                    VStack(alignment: .leading) {
                        Text(file.name)
                            .font(.headline)
                        Text(file.size)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
            }
        }
        .navigationTitle(folderName)
        .onAppear {
            files = getFilesInDirectory(directoryPath: directoryPath)
        }
    }

    /// Opens either another folder view or a file detail view.
    private func destinationView(for file: FileItems) -> some View {
        if file.isDirectory {
            return AnyView(FileDetailListView(directoryPath: file.path, folderName: file.name))
        } else {
            return AnyView(FileDetailView(file: file))
        }
    }
}

/// Detailed view showing full file path and size.
struct FileDetailView: View {
    let file: FileItems

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: file.isDirectory ? "folder.fill" : "doc.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(file.isDirectory ? .blue : .gray)
            
            Text("📂 Name: \(file.name)")
                .font(.title2)
            
            Text("📍 Path: \(file.path)")
                .font(.body)
                .foregroundColor(.gray)
                .lineLimit(3)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("💾 Size: \(file.size)")
                .font(.headline)
                .foregroundColor(.blue)
            
            Spacer()
        }
        .padding()
        .navigationTitle(file.name)
    }
}

#Preview {
    FileListView(directoryPath: NSHomeDirectory() + "/Downloads")
}
