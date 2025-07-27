import Foundation
import ServiceManagement

@MainActor
class LoginItemService: ObservableObject {
    static let shared = LoginItemService()
    
    @Published var isAutoStartEnabled = false
    @Published var lastError: String?
    
    private init() {
        loadAutoStartState()
    }
    
    func toggleAutoStart() {
        lastError = nil
        if isAutoStartEnabled {
            disableAutoStart()
        } else {
            enableAutoStart()
        }
    }
    
    private func enableAutoStart() {
        // For macOS 13+ (Ventura and later), use the new API
        if #available(macOS 13.0, *) {
            do {
                try SMAppService.mainApp.register()
                isAutoStartEnabled = true
                saveAutoStartState()
            } catch {
                print("Failed to enable auto-start: \(error)")
                lastError = "Failed to enable auto-start: \(error.localizedDescription)"
            }
        } else {
            // Fallback for older macOS versions
            enableAutoStartLegacy()
        }
    }
    
    private func disableAutoStart() {
        // For macOS 13+ (Ventura and later), use the new API
        if #available(macOS 13.0, *) {
            do {
                try SMAppService.mainApp.unregister()
                isAutoStartEnabled = false
                saveAutoStartState()
            } catch {
                print("Failed to disable auto-start: \(error)")
                lastError = "Failed to disable auto-start: \(error.localizedDescription)"
            }
        } else {
            // Fallback for older macOS versions
            disableAutoStartLegacy()
        }
    }
    
    private func enableAutoStartLegacy() {
        // Legacy method for older macOS versions
        let appPath = Bundle.main.bundlePath
        let script = """
        tell application "System Events"
            make login item at end with properties {path:"\(appPath)", hidden:true}
        end tell
        """
        
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", script]
        
        do {
            try task.run()
            task.waitUntilExit()
            if task.terminationStatus == 0 {
                isAutoStartEnabled = true
                saveAutoStartState()
            }
        } catch {
            print("Failed to enable auto-start (legacy): \(error)")
        }
    }
    
    private func disableAutoStartLegacy() {
        // Legacy method for older macOS versions
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "checkpoint"
        let script = """
        tell application "System Events"
            delete login item "\(appName)"
        end tell
        """
        
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", script]
        
        do {
            try task.run()
            task.waitUntilExit()
            if task.terminationStatus == 0 {
                isAutoStartEnabled = false
                saveAutoStartState()
            }
        } catch {
            print("Failed to disable auto-start (legacy): \(error)")
        }
    }
    
    private func loadAutoStartState() {
        // For macOS 13+, check using the new API
        if #available(macOS 13.0, *) {
            isAutoStartEnabled = SMAppService.mainApp.status == .enabled
        } else {
            // For older versions, check UserDefaults
            isAutoStartEnabled = UserDefaults.standard.bool(forKey: "checkpoint_auto_start_enabled")
        }
    }
    
    private func saveAutoStartState() {
        // Save state for older macOS versions
        UserDefaults.standard.set(isAutoStartEnabled, forKey: "checkpoint_auto_start_enabled")
    }
} 