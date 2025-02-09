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
            TrashView()
                .tabItem {
                    Label("Trash",systemImage: "Trashtash")
                }
        }.tabViewStyle(.sidebarAdaptable)
    }
}

struct ContentView: View {
    @State private var selectedCategory: Category? = .trashBins
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            SidebarView(selectedCategory: $selectedCategory)
            
            if let category = selectedCategory {
                MainContentView(category: category, searchText: $searchText)
            } else {
                Text("Select a category")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar, label: {
                    Image(systemName: "sidebar.leading")
                })
            }
        }
    }
    
    private func toggleSidebar() {
        #if os(macOS)
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar), with: nil)
        #endif
    }
}

struct SidebarView: View {
    @Binding var selectedCategory: Category?
    
    var body: some View {
        List(selection: $selectedCategory) {
            Section(header: Text("Cleanup")) {
                ForEach(Category.cleanup, id: \ .self) { category in
                    Label(category.rawValue, systemImage: category.iconName)
                }
            }
            
            Section(header: Text("Protection")) {
                ForEach(Category.protection, id: \ .self) { category in
                    Label(category.rawValue, systemImage: category.iconName)
                }
            }
            
            Section(header: Text("Speed")) {
                ForEach(Category.speed, id: \ .self) { category in
                    Label(category.rawValue, systemImage: category.iconName)
                }
            }
            
            Section(header: Text("Applications")) {
                ForEach(Category.applications, id: \ .self) { category in
                    Label(category.rawValue, systemImage: category.iconName)
                }
            }
            
            Section(header: Text("Files")) {
                ForEach(Category.files, id: \ .self) { category in
                    Label(category.rawValue, systemImage: category.iconName)
                }
            }
        }
        .listStyle(SidebarListStyle())
    }
}

struct MainContentView: View {
    let category: Category
    @Binding var searchText: String
    
    @State private var files: [FileItem] = FileItem.sampleData
    
    var filteredFiles: [FileItem] {
        if searchText.isEmpty {
            return files
        } else {
            return files.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(category.rawValue)
                    .font(.title)
                    .bold()
                
                Spacer()
                
                SearchBar(text: $searchText)
            }
            
            List(selection: .constant(Set(filteredFiles.map { $0.id }))) {
                ForEach(filteredFiles) { file in
                    HStack {
                        Image(systemName: file.iconName)
                            .resizable()
                            .frame(width: 24, height: 24)
                        
                        Text(file.name)
                            .font(.body)
                        
                        Spacer()
                        
                        Text(file.size)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 8)
                }
            }
            .listStyle(PlainListStyle())
            
            HStack {
                Spacer()
                
                Button(action: emptyTrash) {
                    Text("Empty")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                
                .padding(.bottom, 20)
            }
        }
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)]), startPoint: .top, endPoint: .bottom))
        .cornerRadius(20)
        .padding()
    }
    
    private func emptyTrash() {
        files.removeAll()
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(8)
        }
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

enum Category: String, CaseIterable, Hashable {
    case systemJunk = "System Junk"
    case mailAttachments = "Mail Attachments"
    case trashBins = "Trash Bins"
    case malwareRemoval = "Malware Removal"
    case privacy = "Privacy"
    case optimization = "Optimization"
    case maintenance = "Maintenance"
    case uninstaller = "Uninstaller"
    case updater = "Updater"
    case extensions = "Extensions"
    case spaceLens = "Space Lens"
    case largeOldFiles = "Large & Old Files"
    case shredder = "Shredder"
    
    var iconName: String {
        switch self {
        case .systemJunk: return "trash"
        case .mailAttachments: return "paperclip"
        case .trashBins: return "trash.circle"
        case .malwareRemoval: return "shield"
        case .privacy: return "lock.shield"
        case .optimization: return "speedometer"
        case .maintenance: return "wrench"
        case .uninstaller: return "square.and.arrow.down"
        case .updater: return "arrow.triangle.2.circlepath"
        case .extensions: return "puzzlepiece"
        case .spaceLens: return "magnifyingglass.circle"
        case .largeOldFiles: return "doc.text"
        case .shredder: return "scissors"
        }
    }
    
    static let cleanup: [Category] = [.systemJunk, .mailAttachments, .trashBins]
    static let protection: [Category] = [.malwareRemoval, .privacy]
    static let speed: [Category] = [.optimization, .maintenance]
    static let applications: [Category] = [.uninstaller, .updater, .extensions]
    static let files: [Category] = [.spaceLens, .largeOldFiles, .shredder]
}

struct FileItem: Identifiable {
    let id = UUID()
    let name: String
    let size: String
    let iconName: String
    
    static let sampleData: [FileItem] = [
        FileItem(name: "3.Body.Problem", size: "4.94 GB", iconName: "folder"),
        FileItem(name: "All.the.Light.We.Cannot.See", size: "3.39 GB", iconName: "folder"),
        FileItem(name: "s2", size: "1.81 GB", iconName: "folder"),
        FileItem(name: "The.Batman.2022.1080p.BluRay.EgyDead.CoM.mp4", size: "1.11 GB", iconName: "film"),
        FileItem(name: "Marvel.What.If.S02E04.EgyDead.CoM.mp4", size: "697.3 MB", iconName: "film"),
        FileItem(name: "Marvel.What.If.S02E05.EgyDead.CoM.mp4", size: "674.3 MB", iconName: "film"),
        FileItem(name: "Marvel.What.If.S02E08.EgyDead.CoM.mp4", size: "655.8 MB", iconName: "film"),
        FileItem(name: "What.If.S02E01.EgyDead.CoM.mp4", size: "634 MB", iconName: "film"),
        FileItem(name: "Marvel.What.If.S02E03.EgyDead.CoM.mp4", size: "606.6 MB", iconName: "film")
    ]
}

#Preview {
    ContentView()
}
