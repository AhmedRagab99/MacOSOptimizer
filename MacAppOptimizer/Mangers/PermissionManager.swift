//
//  PermissionManager.swift
//  MacAppOptimizer
//
//  Created by Ahmed Ragab on 03/02/2025.
//

import Foundation
import SwiftUI
import CoreLocation
import AVFoundation

enum PermissionType {
    case fullDiskAccess
    case camera
    case microphone
    case location
    // Add other permission types as needed
}

class PermissionManager {
    static let shared = PermissionManager()

    // Function to check if a specific permission is granted
    func isPermissionGranted(_ permissionType: PermissionType) -> Bool {
        switch permissionType {
        case .fullDiskAccess:
            return hasFullDiskAccess()
        case .camera:
            return checkCameraPermission()
        case .microphone:
            return checkMicrophonePermission()
        case .location:
            return checkLocationPermission()
        }
    }

    // Function to request a specific permission
    func requestPermission(_ permissionType: PermissionType) {
        switch permissionType {
        case .fullDiskAccess:
            openSystemPreferences(for: .fullDiskAccess)
        case .camera:
            requestCameraPermission()
        case .microphone:
            requestMicrophonePermission()
        case .location:
            requestLocationPermission()
        }
    }

    // Checking Full Disk Access
    private func hasFullDiskAccess() -> Bool {
        let access = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
        return access.first != nil
    }

    // Open System Preferences to guide user for a specific permission
    private func openSystemPreferences(for permission: PermissionType) {
        var url: URL?
        switch permission {
        case .fullDiskAccess:
            url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")
        case .camera:
            url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera")
        case .microphone:
            url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone")
        case .location:
            url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices")
        }
        if let url = url {
            NSWorkspace.shared.open(url)
        }
    }

    // Checking if camera permission is granted (Placeholder)
    private func checkCameraPermission() -> Bool {
        // Camera permission check logic
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }

    // Request camera permission (Placeholder)
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { response in
            // Handle response
        }
    }

    // Checking if microphone permission is granted (Placeholder)
    private func checkMicrophonePermission() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
    }

    // Request microphone permission (Placeholder)
    private func requestMicrophonePermission() {
        AVCaptureDevice.requestAccess(for: .audio) { response in
            // Handle response
        }
    }

    // Checking if location permission is granted (Placeholder)
    private func checkLocationPermission() -> Bool {
        return CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == .authorizedAlways
    }

    // Request location permission (Placeholder)
    private func requestLocationPermission() {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
    }

    // Show a permission denied alert and guide the user to enable the permission
    func showPermissionDeniedAlert(permission: PermissionType) -> Alert {
        let message: String
        switch permission {
        case .fullDiskAccess:
            message = "This app requires Full Disk Access to scan and delete junk files. Please enable Full Disk Access in System Preferences."
        case .camera:
            message = "This app requires Camera access. Please enable Camera in System Preferences."
        case .microphone:
            message = "This app requires Microphone access. Please enable Microphone in System Preferences."
        case .location:
            message = "This app requires Location Services. Please enable Location Services in System Preferences."
        }
        
        return Alert(
            title: Text("Permission Denied"),
            message: Text(message),
            primaryButton: .default(Text("Open Preferences")) {
                self.openSystemPreferences(for: permission)
            },
            secondaryButton: .cancel()
        )
    }
}
