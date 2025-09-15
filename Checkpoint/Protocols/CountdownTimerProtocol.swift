//
//  DataManaging.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 15/09/2025.
//

import Combine
import Foundation

protocol CountdownTimerProtocol: AnyObject {
    var timeRemaining: Duration { get }
    var timeRemainingPublisher: AnyPublisher<Duration, Never> { get }
    var isRunning: Bool { get }

    func start()
    func pause()
    func stop()
    func reset(to duration: Duration)
    func format(timeRemaining: Duration) -> String
}
