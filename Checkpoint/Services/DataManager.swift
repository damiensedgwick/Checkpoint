import Foundation
import Combine

@MainActor
class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var logEntries: [LogEntry] = []
    @Published var currentInterval: TimeInterval = 30 * 60
    @Published var isTimerRunning = false
    @Published var timerStartTime: Date?
    
    private let userDefaults = UserDefaults.standard
    private let logEntriesKey = "checkpoint_log_entries"
    private let currentIntervalKey = "checkpoint_current_interval"
    private let timerStartTimeKey = "checkpoint_timer_start_time"
    
    private init() {
        loadData()
        // Only auto-start timer if we're not resuming from a previous session
        // This prevents the timer from starting when the app is reopened after being closed
        if !isTimerRunning && timerStartTime == nil {
            startTimer()
        }
    }
    
    // MARK: - Data Persistence
    func saveLogEntry(_ entry: LogEntry) {
        logEntries.insert(entry, at: 0)
        saveLogEntries()
    }
    
    func deleteLogEntry(_ entry: LogEntry) {
        logEntries.removeAll { $0.id == entry.id }
        saveLogEntries()
    }
    
    func clearAllLogs() {
        logEntries.removeAll()
        saveLogEntries()
    }
    
    func updateInterval(_ interval: TimeInterval) {
        currentInterval = interval
        userDefaults.set(interval, forKey: currentIntervalKey)
    }
    
    // MARK: - Timer Management
    func startTimer() {
        isTimerRunning = true
        timerStartTime = Date()
        userDefaults.set(timerStartTime?.timeIntervalSince1970, forKey: timerStartTimeKey)
    }
    
    func stopTimer() {
        isTimerRunning = false
        timerStartTime = nil
        userDefaults.removeObject(forKey: timerStartTimeKey)
    }
    
    func stopTimerAndClear() {
        stopTimer()
        // Also clear any persisted timer state to prevent resuming on next launch
        userDefaults.removeObject(forKey: timerStartTimeKey)
    }
    
    var elapsedTime: TimeInterval {
        guard let startTime = timerStartTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }
    
    var remainingTime: TimeInterval {
        max(0, currentInterval - elapsedTime)
    }
    
    var isTimerComplete: Bool {
        elapsedTime >= currentInterval
    }
    
    // MARK: - Private Methods
    private func loadData() {
        // Load log entries
        if let data = userDefaults.data(forKey: logEntriesKey),
           let entries = try? JSONDecoder().decode([LogEntry].self, from: data) {
            logEntries = entries
        }
        
        // Load current interval
        currentInterval = userDefaults.double(forKey: currentIntervalKey)
        if currentInterval == 0 {
            currentInterval = 30 * 60 // Default to 30 minutes
        }
        
        // Load timer state
        if let startTimeInterval = userDefaults.object(forKey: timerStartTimeKey) as? TimeInterval {
            timerStartTime = Date(timeIntervalSince1970: startTimeInterval)
            isTimerRunning = true
        }
    }
    
    private func saveLogEntries() {
        if let data = try? JSONEncoder().encode(logEntries) {
            userDefaults.set(data, forKey: logEntriesKey)
        }
    }
} 