//
//  AppMenuViewModel.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 15/09/2025.
//

import Combine
import Foundation

@MainActor
class CountdownTimerViewModel: ObservableObject {
    @Published var timeRemaining: Duration = .seconds(1800)
    @Published var isRunning: Bool = false

    private let countdownTimerService: CountdownTimerProtocol
    private var cancellables = Set<AnyCancellable>()

    init(countdownTimerService: CountdownTimerProtocol) {
        self.countdownTimerService = countdownTimerService

        countdownTimerService.timeRemainingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] duration in
                self?.timeRemaining = duration
            }
            .store(in: &cancellables)

        if let service = countdownTimerService as? CountdownTimerService {
            service.$isRunning
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isRunning in
                    self?.isRunning = isRunning
                }
                .store(in: &cancellables)
        }
    }

    convenience init() {
        self.init(countdownTimerService: CountdownTimerService())
    }

    func start() {
        countdownTimerService.start()
    }

    func pause() {
        countdownTimerService.pause()
    }

    func stop() {
        countdownTimerService.stop()
    }

    func reset(to duration: Duration) {
        countdownTimerService.reset(to: duration)
    }

    var formattedTimeRemaining: String {
        countdownTimerService.format(timeRemaining: timeRemaining)
    }
}
