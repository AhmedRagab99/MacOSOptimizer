//
//  ContentView.swift
//  MacAppOptimizer
//
//  Created by Ahmed Ragab on 03/02/2025.
//

import SwiftUI
import Foundation
import IOKit
import Darwin
import MachO
import Foundation
import SwiftUI





struct MainView: View {
    var body: some View {
        TabView {
//            SystemMonitorView()
//                .tabItem {
//                    Label("Monitor", systemImage: "gauge")
//                }
            
            JunkFileCleanupView()
                .tabItem {
                    Label("Junk Cleanup", systemImage: "trash")
                }
//            FileListView(directoryPath: NSHomeDirectory() + "/Downloads")
//                .tabItem {
//                    Label("Junk Cleanup", systemImage: "trash")
//                }
//
//            DuplicateFinderView()
//                .tabItem {
//                    Label("Duplicates", systemImage: "doc.on.doc")
//                }
//            
//            StartupItemsManagerView()
//                .tabItem {
//                    Label("Startup Items", systemImage: "arrow.triangle.2.circlepath")
//                }
//            
//            AppUninstallerView()
//                .tabItem {
//                    Label("Uninstaller", systemImage: "xmark.bin")
//                }
            InstalledAppsView()
                .tabItem {
                    Label("installed", systemImage: "xmark.bin")
                }
        }
    }
}


//

//import SwiftUI
//
//struct StartupItemsManagerView: View {
//    @State private var startupItems: [String] = getStartupItems()
//
//    var body: some View {
//        VStack {
//            Text("Startup Items Manager").font(.title2).bold()
//
//            List(startupItems, id: \.self) { item in
//                HStack {
//                    Text(item)
//                    Spacer()
//                    Button("Remove") {
//                        removeStartupItem(name: item)
//                        startupItems = getStartupItems()
//                    }
//                    .buttonStyle(.bordered)
//                }
//            }
//
//            Spacer()
//        }
//        .padding()
//    }
//}
//
//import SwiftUI
//
//struct AppUninstallerView: View {
//    @State private var installedApps: [URL] = getInstalledApps()
//
//    var body: some View {
//        VStack {
//            Text("App Uninstaller").font(.title2).bold()
//
//            List(installedApps, id: \.self) { app in
//                HStack {
//                    Text(app.lastPathComponent)
//                    Spacer()
//                    Button("Uninstall") {
//                        uninstallApp(app)
//                        installedApps = getInstalledApps()
//                    }
//                    .buttonStyle(.bordered)
//                }
//            }
//
//            Spacer()
//        }
//        .padding()
//    }
//}

import Foundation

struct ContentView: View {
    var body: some View {
        Text("test here")
    }
}
#Preview {
    MainView()
}
