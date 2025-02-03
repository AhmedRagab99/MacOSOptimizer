//
//  AppItem.swift
//  MacAppOptimizer
//
//  Created by Ahmed Ragab on 03/02/2025.
//

import SwiftUI
import AppKit
// AppItem model to store app info
struct AppItem: Identifiable {
    var id: String { path } // Use path as unique identifier
    let name: String
    let path: String
    let size: Int64 // The size of the app in bytes
}

// Get list of installed apps
func getInstalledApps() -> [AppItem] {
    let fileManager = FileManager.default
    var installedApps: [AppItem] = []
    
    // Directories to scan for apps
    let directories: [URL] = [
        URL(fileURLWithPath: "/Applications"),
        URL(fileURLWithPath: "\(NSHomeDirectory())/Applications")
    ]
    
    for directory in directories {
        do {
            let contents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            for item in contents {
                if item.pathExtension.lowercased() == "app" {
                    let size = getAppSize(from: item.path) // Get app size
                    let appItem = AppItem(name: item.lastPathComponent, path: item.path, size: size)
                    installedApps.append(appItem)
                }
            }
        } catch {
            print("Error reading directory: \(error)")
        }
    }
    
    return installedApps
}

// Get app icon from path
func getAppIcon(from appPath: String) -> Image? {
    let workspace = NSWorkspace.shared
    let appIcon = workspace.icon(forFile: appPath)
    return Image(nsImage: appIcon)
}

// Get the size of the application
func getAppSize(from appPath: String) -> Int64 {
    let fileManager = FileManager.default
    let resourceValues = try? fileManager.attributesOfItem(atPath: appPath)
    
    if let fileSize = resourceValues?[.size] as? Int64 {
        return fileSize
    }
    return 0
}

// Installed Apps view
struct InstalledAppsView: View {
    @State private var installedApps: [AppItem] = []
    
    var body: some View {
//        NavigationView {
            List(installedApps) { app in
//                NavigationLink(destination: AppDetailView(app: app)) {
                    HStack {
                        if let appIcon = getAppIcon(from: app.path) {
                            appIcon
                                .resizable()
                                .frame(width: 40, height: 40)
                                .cornerRadius(8)
                        } else {
                            Image(systemName: "app.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .cornerRadius(8)
                        }

                        Text(app.name)
                            .font(.headline)
                        
                        Spacer()
                    }
                    .padding(.vertical, 5)
                }
//            }
            .navigationTitle("Installed Apps")
            .onAppear {
                installedApps = getInstalledApps()  // Load installed apps on view appear
            }
//        }
    }
}

// App Detail View
struct AppDetailView: View {
    let app: AppItem

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(app.name)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            HStack {
                Text("Path: ")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(app.path)
                    .font(.body)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
            
            HStack {
                Text("Size: ")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("\(ByteCountFormatter.string(fromByteCount: app.size, countStyle: .file))")
                    .font(.body)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("App Details")
    }
}

#Preview {
    InstalledAppsView()
}
