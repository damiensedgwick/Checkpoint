import Foundation
import Combine
import UserNotifications

@MainActor
class TimerService: ObservableObject {
    static let shared = TimerService()
    
    @Published var timeRemaining: TimeInterval = 0
    @Published var isActive = false
    
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
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
        
        if DataManager.shared.isTimerComplete {
            stopTimer()
            DataManager.shared.stopTimer()
            showTimerCompleteNotification()
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    private func showTimerCompleteNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Checkpoint Timer Complete"
        content.body = "Time to log your work!"
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: "timer-complete", content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error)")
            }
        }
    }
    
    // MARK: - Public Methods
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
} 