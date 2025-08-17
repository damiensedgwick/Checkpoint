import Foundation
import SwiftUI
import AppKit

extension Notification.Name {
    static let loggingWindowOpened = Notification.Name("loggingWindowOpened")
    static let loggingWindowClosed = Notification.Name("loggingWindowClosed")
}

@MainActor
class WindowService: ObservableObject {
    static let shared = WindowService()
    
    @Published var shouldOpenLoggingWindow = false
    @Published var isLoggingWindowOpen = false
    
    private init() {
        setupNotificationHandling()
    }
    
    private func setupNotificationHandling() {
        NotificationCenter.default.addObserver(
            forName: .openLoggingWindow,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.shouldOpenLoggingWindow = true
            }
        }
    }
    
    func openLoggingWindow() {
        // Check if a logging window is already open
        if checkIfLoggingWindowIsOpen() {
            // If window exists, just bring it to front
            bringLoggingWindowToFront()
        } else {
            // Only set flag to open new window if none exists
            shouldOpenLoggingWindow = true
        }
    }
    
    func checkIfLoggingWindowIsOpen() -> Bool {
        return NSApplication.shared.windows.contains { window in
            window.identifier?.rawValue == "logging"
        }
    }
    
    func bringLoggingWindowToFront() {
        // Activate the app to bring it to the front
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        // Find the logging window and bring it to the front
        if let window = NSApplication.shared.windows.first(where: { window in
            window.identifier?.rawValue == "logging"
        }) {
            window.makeKeyAndOrderFront(nil)
            window.orderFrontRegardless()
        }
    }
    
    func notifyLoggingWindowOpened() {
        isLoggingWindowOpen = true
        NotificationCenter.default.post(name: .loggingWindowOpened, object: nil)
    }
    
    func notifyLoggingWindowClosed() {
        isLoggingWindowOpen = false
        NotificationCenter.default.post(name: .loggingWindowClosed, object: nil)
    }
} 