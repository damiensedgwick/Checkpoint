import Foundation
import SwiftUI
import Combine

@MainActor
class CheckpointAppViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isTimerRunning = false
    @Published var timeRemaining: TimeInterval = 0
    @Published var currentInterval: TimeInterval = 30 * 60
    @Published var shouldOpenLoggingWindow = false
    
    // MARK: - Services
    private let dataManager: DataManager
    private let timerService: TimerService
    private let windowService: WindowService
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(dataManager: DataManager,
         timerService: TimerService,
         windowService: WindowService) {
        self.dataManager = dataManager
        self.timerService = timerService
        self.windowService = windowService
        
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Bind timer state
        dataManager.$isTimerRunning
            .assign(to: \.isTimerRunning, on: self)
            .store(in: &cancellables)
        
        // Bind time remaining
        timerService.$timeRemaining
            .assign(to: \.timeRemaining, on: self)
            .store(in: &cancellables)
        
        // Bind current interval
        dataManager.$currentInterval
            .assign(to: \.currentInterval, on: self)
            .store(in: &cancellables)
        
        // Bind window service
        windowService.$shouldOpenLoggingWindow
            .assign(to: \.shouldOpenLoggingWindow, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func startTimer() {
        dataManager.startTimer()
    }
    
    func stopTimer() {
        dataManager.stopTimer()
    }
    
    func stopTimerAndClear() {
        dataManager.stopTimerAndClear()
    }
    
    func updateInterval(_ interval: TimeInterval) {
        dataManager.updateInterval(interval)
    }
    
    func formatTime(_ timeInterval: TimeInterval) -> String {
        return timerService.formatTime(timeInterval)
    }
    
    func openLoggingWindow() {
        windowService.openLoggingWindow()
    }
    
    func bringLoggingWindowToFront() {
        windowService.bringLoggingWindowToFront()
    }
    
    // MARK: - Computed Properties
    var elapsedTime: TimeInterval {
        return dataManager.elapsedTime
    }
    
    var remainingTime: TimeInterval {
        return dataManager.remainingTime
    }
    
    var isTimerComplete: Bool {
        return dataManager.isTimerComplete
    }
}
