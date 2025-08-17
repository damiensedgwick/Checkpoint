import Foundation
import SwiftUI
import Combine

@MainActor
class MenuBarViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isTimerRunning = false
    @Published var currentInterval: TimeInterval = 30 * 60
    @Published var isLoggingWindowOpen = false
    @Published var isTimerPaused = false
    
    // MARK: - Services
    private let dataManager: DataManager
    private let windowService: WindowService
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Constants
    var intervals: [TimeInterval] {
        var baseIntervals: [TimeInterval] = [
            15 * 60,  // 15 minutes
            30 * 60,  // 30 minutes
            45 * 60,  // 45 minutes
            60 * 60,  // 60 minutes (1 hour)
            120 * 60  // 120 minutes (2 hours)
        ]
        
        #if DEBUG
        // Add 1-minute interval for testing only
        baseIntervals.insert(60, at: 0)  // 1 minute
        #endif
        
        return baseIntervals
    }
    
    // MARK: - Initialization
    init(dataManager: DataManager,
         windowService: WindowService) {
        self.dataManager = dataManager
        self.windowService = windowService
        
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        dataManager.$isTimerRunning
            .assign(to: \.isTimerRunning, on: self)
            .store(in: &cancellables)
        
        dataManager.$currentInterval
            .assign(to: \.currentInterval, on: self)
            .store(in: &cancellables)
        
        windowService.$isLoggingWindowOpen
            .assign(to: \.isLoggingWindowOpen, on: self)
            .store(in: &cancellables)
        
        dataManager.$isTimerPaused
            .assign(to: \.isTimerPaused, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func toggleTimer() {
        // Don't allow starting timer if logging window is open
        if isLoggingWindowOpen && !isTimerRunning {
            return
        }
        
        if isTimerRunning {
            dataManager.stopTimer()
        } else {
            dataManager.startTimer()
        }
    }
    
    func togglePauseTimer() {
        if isTimerPaused {
            dataManager.resumeTimer()
        } else {
            dataManager.pauseTimer()
        }
    }
    
    func updateInterval(_ interval: TimeInterval) {
        dataManager.updateInterval(interval)
    }
    
    func openLoggingWindow() {
        windowService.openLoggingWindow()
        // Bring the window to the front after a brief delay to ensure it's created
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.windowService.bringLoggingWindowToFront()
        }
    }
    
    func quitApp() {
        // Stop the timer and clear persisted state before quitting
        dataManager.stopTimerAndClear()
        NSApplication.shared.terminate(nil)
    }
    
    // MARK: - Helper Methods
    func formatInterval(_ interval: TimeInterval) -> String {
        let minutes = Int(interval / 60)
        if minutes >= 60 {
            let hours = minutes / 60
            return "\(hours) hour\(hours == 1 ? "" : "s")"
        } else {
            return "\(minutes) min\(minutes == 1 ? "" : "s")"
        }
    }
    
    func isCurrentInterval(_ interval: TimeInterval) -> Bool {
        return interval == currentInterval
    }
}
