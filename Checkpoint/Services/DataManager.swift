import Foundation
import Combine

@MainActor
class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var logEntries: [LogEntry] = []
    @Published var currentInterval: TimeInterval = 30 * 60
    @Published var isTimerRunning = false
    @Published var timerStartTime: Date?
    @Published var isTimerPaused = false
    @Published var pausedTimeRemaining: TimeInterval = 0
    
    private let userDefaults = UserDefaults.standard
    private let logEntriesKey = "checkpoint_log_entries"
    private let currentIntervalKey = "checkpoint_current_interval"
    private let timerStartTimeKey = "checkpoint_timer_start_time"
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadData()
        setupNotificationHandling()
        // Only auto-start timer if we're not resuming from a previous session
        // This prevents the timer from starting when the app is reopened after being closed
        if !isTimerRunning && timerStartTime == nil {
            startTimer()
        }
    }
    
    private func setupNotificationHandling() {
        NotificationCenter.default.addObserver(
            forName: .loggingWindowOpened,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.pauseTimer()
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: .loggingWindowClosed,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.resumeTimer()
                // Also start a new timer if the previous one had completed
                self?.startNewTimerAfterLogging()
            }
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
        // Don't start timer if logging window is open
        if WindowService.shared.isLoggingWindowOpen {
            return
        }
        
        isTimerRunning = true
        isTimerPaused = false
        timerStartTime = Date()
        userDefaults.set(timerStartTime?.timeIntervalSince1970, forKey: timerStartTimeKey)
    }
    
    func stopTimer() {
        isTimerRunning = false
        isTimerPaused = false
        timerStartTime = nil
        pausedTimeRemaining = 0
        userDefaults.removeObject(forKey: timerStartTimeKey)
    }
    
    func stopTimerAndClear() {
        stopTimer()
        // Also clear any persisted timer state to prevent resuming on next launch
        userDefaults.removeObject(forKey: timerStartTimeKey)
    }
    
    func pauseTimer() {
        guard isTimerRunning && !isTimerPaused else { return }
        
        isTimerPaused = true
        pausedTimeRemaining = remainingTime
        // Keep the timer start time so we can calculate the pause duration
    }
    
    func resumeTimer() {
        guard isTimerPaused else { return }
        
        isTimerPaused = false
        // Adjust the start time to account for the pause duration
        if timerStartTime != nil {
            let pauseDuration = currentInterval - pausedTimeRemaining
            timerStartTime = Date().addingTimeInterval(-pauseDuration)
            userDefaults.set(timerStartTime?.timeIntervalSince1970, forKey: timerStartTimeKey)
        }
        pausedTimeRemaining = 0
    }
    
    func startNewTimerAfterLogging() {
        // If timer was completed (not just paused), start a fresh timer
        if !isTimerRunning && timerStartTime == nil {
            startTimer()
        }
    }
    
    var elapsedTime: TimeInterval {
        guard let startTime = timerStartTime else { return 0 }
        
        if isTimerPaused {
            return currentInterval - pausedTimeRemaining
        } else {
            return Date().timeIntervalSince(startTime)
        }
    }
    
    var remainingTime: TimeInterval {
        if isTimerPaused {
            return pausedTimeRemaining
        } else {
            return max(0, currentInterval - elapsedTime)
        }
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