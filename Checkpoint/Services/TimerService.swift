import Foundation
import Combine
import UserNotifications

extension Notification.Name {
    static let timerCompleted = Notification.Name("timerCompleted")
    static let openLoggingWindow = Notification.Name("openLoggingWindow")
    static let timerPaused = Notification.Name("timerPaused")
    static let timerResumed = Notification.Name("timerResumed")
}

@MainActor
class TimerService: ObservableObject {
    static let shared = TimerService()
    
    @Published var timeRemaining: TimeInterval = 0
    @Published var isActive = false
    
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private var isRestarting = false
    
    private init() {
        setupBindings()
        setupNotificationHandling()
        requestNotificationPermission()
    }
    
    private func setupBindings() {
        DataManager.shared.$isTimerRunning
            .sink { [weak self] isRunning in
                self?.isActive = isRunning
                if isRunning {
                    self?.startTimer()
                } else {
                    self?.stopTimer()
                }
            }
            .store(in: &cancellables)
        
        DataManager.shared.$currentInterval
            .sink { [weak self] _ in
                self?.updateTimeRemaining()
            }
            .store(in: &cancellables)
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
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: .timerPaused,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.pauseTimer()
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: .timerResumed,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.resumeTimer()
            }
        }
    }
    
    private func startTimer() {
        // Only stop the timer object, don't reset timeRemaining
        timer?.invalidate()
        timer = nil
        
        // Only start the timer if not paused
        if !DataManager.shared.isTimerPaused {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    self?.updateTimeRemaining()
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        timeRemaining = 0
    }
    
    private func pauseTimer() {
        // Stop the timer object to prevent background counting
        timer?.invalidate()
        timer = nil
        // Keep timeRemaining as is - don't reset it
        // The DataManager.pausedTimeRemaining will store the current remaining time
    }
    
    private func resumeTimer() {
        // Restart the timer if it should be running and not paused
        if DataManager.shared.isTimerRunning && !DataManager.shared.isTimerPaused {
            // Don't call updateTimeRemaining() here - it would recalculate from DataManager
            // and potentially cause time jumping. Just restart the timer object.
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    self?.updateTimeRemaining()
                }
            }
        }
    }
    
    private func updateTimeRemaining() {
        // Don't update if timer is paused
        if DataManager.shared.isTimerPaused {
            return
        }
        
        timeRemaining = DataManager.shared.remainingTime
        
        if DataManager.shared.isTimerComplete && !isRestarting {
            isRestarting = true
            
            // Stop the current timer first
            stopTimer()
            DataManager.shared.stopTimer()
            
            // Show notification
            showTimerCompleteNotification()
            
            // Open logging window
            openLoggingWindow()
            
            // Don't restart timer automatically - it will be paused when logging window opens
            // Timer will resume when logging window closes
            self.isRestarting = false
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Notification permission error: \(error)")
                } else if granted {
                    print("Notification permission granted")
                } else {
                    print("Notification permission denied - notifications will be disabled")
                }
            }
        }
    }
    
    private func showTimerCompleteNotification() {
        // Check notification settings first
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .authorized {
                    let content = UNMutableNotificationContent()
                    content.title = "Checkpoint Timer Complete"
                    content.body = "Time to log your work! A new timer will start automatically."
                    content.sound = .default
                    
                    let request = UNNotificationRequest(identifier: "timer-complete", content: content, trigger: nil)
                    
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print("Notification error: \(error)")
                        }
                        // Always post the notification for UI updates regardless of notification success
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: .timerCompleted, object: nil)
                        }
                    }
                } else {
                    print("Notifications not authorized - skipping notification")
                    // Still post the notification for UI updates
                    NotificationCenter.default.post(name: .timerCompleted, object: nil)
                }
            }
        }
    }
    
    // MARK: - Public Methods
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let totalSeconds = Int(timeInterval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    private func openLoggingWindow() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .openLoggingWindow, object: nil)
        }
    }
} 