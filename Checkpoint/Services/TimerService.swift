import Foundation
import Combine
import UserNotifications

extension Notification.Name {
    static let timerCompleted = Notification.Name("timerCompleted")
    static let openLoggingWindow = Notification.Name("openLoggingWindow")
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
    
    private func startTimer() {
        stopTimer()
        updateTimeRemaining()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateTimeRemaining()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        timeRemaining = 0
    }
    
    private func updateTimeRemaining() {
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
            
            // Restart timer after a brief delay to avoid race conditions
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                DataManager.shared.startTimer()
                self.isRestarting = false
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            } else if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }
    
    private func showTimerCompleteNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Checkpoint Timer Complete"
        content.body = "Time to log your work! A new timer will start automatically."
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: "timer-complete", content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error)")
                // Fallback: just post the notification for UI updates
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .timerCompleted, object: nil)
                }
            } else {
                // Post a notification that can be used to trigger UI updates
                NotificationCenter.default.post(name: .timerCompleted, object: nil)
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