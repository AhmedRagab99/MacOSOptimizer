//
//  SystemMonitorView.swift
//  MacAppOptimizer
//
//  Created by Ahmed Ragab on 03/02/2025.
//



import SwiftUI
import Darwin
import IOKit
import MachO

struct SystemMonitorView: View {
    @State private var cpuUsage: Double = 0.0
    @State private var memoryUsage: (used: Double, total: Double) = (0, 0)
    @State private var diskUsage: (used: Double, total: Double) = (0, 0)

    var body: some View {
        VStack {
            Text("System Performance Monitor").font(.title2).bold()

            VStack(alignment: .leading) {
                Text("CPU Usage: \(String(format: "%.2f", cpuUsage))%")
                Text("RAM Usage: \(String(format: "%.2f", memoryUsage.used)) / \(String(format: "%.2f", memoryUsage.total)) GB")
                Text("Disk Usage: \(String(format: "%.2f", diskUsage.used)) / \(String(format: "%.2f", diskUsage.total)) GB")
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2)))
            .padding()

            Button("Free Memory", action: freeMemory)
                .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
        .onAppear(perform: updateStats)
    }
    
    private func updateStats() {
        cpuUsage = getCPUUsage()
        memoryUsage = getMemoryInfo()
        diskUsage = getDiskUsage()
    }
    // Fetches memory usage statistics on macOS.
    /// - Returns: A tuple containing:
    ///   - `used`: The amount of memory currently in use (in GB).
    ///   - `total`: The total system memory available (in GB).
    func getMemoryInfo() -> (used: Double, total: Double) {
        var stats = vm_statistics64()  // Structure to hold memory statistics
        var size = mach_msg_type_number_t(MemoryLayout.size(ofValue: stats) / MemoryLayout<integer_t>.size)
        
        let hostPort = mach_host_self()  // Get reference to the host (system)

        // Fetch memory statistics
        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
                host_statistics64(hostPort, HOST_VM_INFO64, $0, &size)
            }
        }
        
        // Check if the call was successful
        guard result == KERN_SUCCESS else {
            print("❌ Failed to fetch memory usage")
            return (0, 0)
        }
        
        let pageSize = vm_kernel_page_size  // Size of a memory page in bytes
        
        // Calculate used memory by summing different memory states
        let usedMemory = Double(stats.active_count + stats.inactive_count + stats.wire_count) * Double(pageSize) / (1024 * 1024 * 1024) // Convert bytes to GB
        
        // Get total physical memory available
        let totalMemory = Double(ProcessInfo.processInfo.physicalMemory) / (1024 * 1024 * 1024) // Convert bytes to GB
        
        return (usedMemory, totalMemory)
    }

    // MARK: - Memory Purging

    /// Attempts to free up memory using the `purge` command (requires admin permissions).
    /// - Note: `purge` clears inactive memory, making RAM more available.
    func freeMemory() {
        let process = Process()
        process.launchPath = "/usr/bin/purge"  // System command to clear memory
        process.launch()
    }

    // MARK: - CPU Usage Information

    /// Retrieves current CPU usage as a percentage.
    /// - Returns: CPU usage percentage (0-100%).
    func getCPUUsage() -> Double {
        var cpuLoad = host_cpu_load_info()  // Structure to hold CPU statistics
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)
        
        // Fetch CPU statistics
        let result = withUnsafeMutablePointer(to: &cpuLoad) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        
        // Check if the call was successful
        guard result == KERN_SUCCESS else {
            print("❌ Failed to fetch CPU usage")
            return 0
        }
        
        // CPU time categories (measured in system clock ticks)
        let userTime = Double(cpuLoad.cpu_ticks.0)   // Time spent in user mode
        let systemTime = Double(cpuLoad.cpu_ticks.1) // Time spent in kernel mode
        let idleTime = Double(cpuLoad.cpu_ticks.2)   // Idle CPU time
        let niceTime = Double(cpuLoad.cpu_ticks.3)   // Low-priority background processes

        let totalTime = userTime + systemTime + idleTime + niceTime
        let usagePercentage = ((userTime + systemTime + niceTime) / totalTime) * 100.0  // CPU usage percentage

        return usagePercentage
    }
    func getDiskUsage() -> (used: Double, total: Double) {
        let fileManager = FileManager.default
        let url = fileManager.homeDirectoryForCurrentUser
        
        do {
            let attributes = try fileManager.attributesOfFileSystem(forPath: url.path)
            if let totalSize = attributes[.systemSize] as? NSNumber,
               let freeSize = attributes[.systemFreeSize] as? NSNumber {
                let total = totalSize.doubleValue / (1024 * 1024 * 1024)
                let free = freeSize.doubleValue / (1024 * 1024 * 1024)
                let used = total - free
                return (used, total)
            }
        } catch {
            print("Error retrieving disk usage: \(error.localizedDescription)")
        }
        
        return (0, 0)
    }
}

#Preview {
    SystemMonitorView()
}
