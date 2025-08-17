import Foundation
import SwiftUI
import Combine

@MainActor
class TimerLabelViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var timeRemaining: TimeInterval = 0
    @Published var isTimerRunning = false
    @Published var isTimerPaused = false
    
    // MARK: - Services
    private let dataManager: DataManager
    private let timerService: TimerService
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(dataManager: DataManager,
         timerService: TimerService) {
        self.dataManager = dataManager
        self.timerService = timerService
        
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        timerService.$timeRemaining
            .assign(to: \.timeRemaining, on: self)
            .store(in: &cancellables)
        
        dataManager.$isTimerRunning
            .assign(to: \.isTimerRunning, on: self)
            .store(in: &cancellables)
        
        dataManager.$isTimerPaused
            .assign(to: \.isTimerPaused, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func formatTime(_ timeInterval: TimeInterval) -> String {
        return timerService.formatTime(timeInterval)
    }
    
    // MARK: - Computed Properties
    var shouldShowTimer: Bool {
        return timeRemaining > 0
    }
    
    var timerColor: Color {
        if isTimerPaused {
            return .secondary // Show paused timer in secondary color
        } else if timeRemaining < 300 {
            return .red
        } else {
            return .primary
        }
    }
    
    var formattedTimeRemaining: String {
        let timeString = formatTime(timeRemaining)
        return isTimerPaused ? "⏸ \(timeString)" : timeString
    }
}
