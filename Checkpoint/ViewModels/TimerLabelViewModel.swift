import Foundation
import SwiftUI
import Combine

@MainActor
class TimerLabelViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var timeRemaining: TimeInterval = 0
    @Published var isTimerRunning = false
    
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
        return timeRemaining < 300 ? .red : .primary
    }
    
    var formattedTimeRemaining: String {
        return formatTime(timeRemaining)
    }
}
