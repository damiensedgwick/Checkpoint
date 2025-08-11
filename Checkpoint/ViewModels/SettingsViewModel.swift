import Foundation
import SwiftUI
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var showingResetAlert = false
    @Published var showingExportSheet = false
    @Published var showingExportAlert = false
    @Published var exportAlertMessage = ""
    @Published var showingAutoStartAlert = false
    @Published var autoStartAlertMessage = ""
    @Published var logEntries: [LogEntry] = []
    @Published var isAutoStartEnabled = false
    @Published var lastError: String?
    
    // MARK: - Services
    private let dataManager: DataManager
    private let loginItemService: LoginItemService
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Constants
    let intervals: [(String, TimeInterval)] = [
        ("15 minutes", 15 * 60),
        ("30 minutes", 30 * 60),
        ("45 minutes", 45 * 60),
        ("1 hour", 60 * 60),
        ("2 hours", 120 * 60)
    ]
    
    // MARK: - Initialization
    init(dataManager: DataManager,
         loginItemService: LoginItemService) {
        self.dataManager = dataManager
        self.loginItemService = loginItemService
        
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        dataManager.$logEntries
            .assign(to: \.logEntries, on: self)
            .store(in: &cancellables)
        
        loginItemService.$isAutoStartEnabled
            .assign(to: \.isAutoStartEnabled, on: self)
            .store(in: &cancellables)
        
        loginItemService.$lastError
            .assign(to: \.lastError, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func toggleAutoStart() {
        loginItemService.toggleAutoStart()
    }
    
    func exportLogs() {
        if logEntries.isEmpty {
            exportAlertMessage = "No logs to export. Please create some log entries first."
            showingExportAlert = true
        } else {
            showingExportSheet = true
        }
    }
    
    func resetAllData() {
        showingResetAlert = true
    }
    
    func confirmReset() {
        dataManager.clearAllLogs()
    }
    
    func clearError() {
        lastError = nil
    }
    
    // MARK: - Computed Properties
    var hasLogs: Bool {
        return !logEntries.isEmpty
    }
    
    var logCount: Int {
        return logEntries.count
    }
    
    var hasError: Bool {
        return lastError != nil
    }
}
