import Foundation
import SwiftUI

@MainActor
class WindowService: ObservableObject {
    static let shared = WindowService()
    
    @Published var shouldOpenLoggingWindow = false
    
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
        shouldOpenLoggingWindow = true
    }
} 