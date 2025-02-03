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
            SystemMonitorView()
                .tabItem {
                    Label("Monitor", systemImage: "gauge")
                }            
            JunkFileCleanupView()
                .tabItem {
                    Label("Junk Cleanup", systemImage: "trash")
                }
            
            DuplicateFinderView()
                .tabItem {
                    Label("Duplicates", systemImage: "doc.on.doc")
                }

            InstalledAppsView()
                .tabItem {
                    Label("installed", systemImage: "xmark.bin")
                }
        }.tabViewStyle(.sidebarAdaptable)
    }
}


import Foundation

struct ContentView: View {
    var body: some View {
        Text("test here")
    }
}
#Preview {
    MainView()
}
