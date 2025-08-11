import Foundation
import SwiftUI
import UserNotifications
import Combine

@MainActor
class LoggingViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var project = ""
    @Published var description = ""
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var showingSuccess = false
    
    // MARK: - Services
    private let dataManager: DataManager
    
    // MARK: - Initialization
    init(dataManager: DataManager) {
        self.dataManager = dataManager
    }
    
    // MARK: - Public Methods
    func saveLog() -> Bool {
        guard validateInput() else { return false }
        
        let entry = LogEntry(
            project: project.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        dataManager.saveLogEntry(entry)
        showSuccessNotification()
        return true
    }
    
    func clearForm() {
        project = ""
        description = ""
    }
    
    func resetState() {
        clearForm()
        showingAlert = false
        showingSuccess = false
        alertMessage = ""
    }
    
    // MARK: - Private Methods
    private func validateInput() -> Bool {
        if project.isEmpty {
            alertMessage = "Please enter a project name"
            showingAlert = true
            return false
        }
        
        if description.isEmpty {
            alertMessage = "Please enter a description"
            showingAlert = true
            return false
        }
        
        return true
    }
    
    private func showSuccessNotification() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                let content = UNMutableNotificationContent()
                content.title = "Log Saved"
                content.body = "Your work has been logged successfully"
                content.sound = .default
                
                let request = UNNotificationRequest(identifier: "log-saved", content: content, trigger: nil)
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Notification error: \(error)")
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    var isFormValid: Bool {
        return !project.isEmpty && !description.isEmpty
    }
}
