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
    @Published var pauseStartTime: Date?
    @Published var totalPauseDuration: TimeInterval = 0
    
    private let userDefaults = UserDefaults.standard
    private let logEntriesKey = "checkpoint_log_entries"
    private let currentIntervalKey = "checkpoint_current_interval"
    private let timerStartTimeKey = "checkpoint_timer_start_time"
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadData()
        setupNotificationHandling()
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
    
    // MARK: - Public Methods
    func startTimer() {
        guard !isTimerRunning else { return }
        
        isTimerRunning = true
        isTimerPaused = false
        timerStartTime = Date()
        totalPauseDuration = 0
        userDefaults.set(timerStartTime?.timeIntervalSince1970, forKey: timerStartTimeKey)
    }
    
    func stopTimer() {
        isTimerRunning = false
        isTimerPaused = false
        timerStartTime = nil
        pausedTimeRemaining = 0
        pauseStartTime = nil
        totalPauseDuration = 0
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
        pauseStartTime = Date()
        // Keep the timer start time so we can calculate the pause duration
        
        // Notify that timer was paused
        NotificationCenter.default.post(name: .timerPaused, object: nil)
    }
    
    func resumeTimer() {
        guard isTimerPaused else { return }
        
        isTimerPaused = false
        // Add the current pause duration to the total
        if let pauseStart = pauseStartTime {
            totalPauseDuration += Date().timeIntervalSince(pauseStart)
        }
        pauseStartTime = nil
        
        // Notify that timer was resumed
        NotificationCenter.default.post(name: .timerResumed, object: nil)
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
            // If currently paused, return the time that had elapsed before pause
            return currentInterval - pausedTimeRemaining
        } else {
            // Calculate total elapsed time minus total pause duration
            let totalElapsed = Date().timeIntervalSince(startTime)
            return totalElapsed - totalPauseDuration
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