//
//  DataManager.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 14/09/2025.
//

import Combine
import Foundation

// This service keeps its public API the same but uses Swift Concurrency under the hood.
// It exposes Combine publishers so existing ViewModels continue to work without changes.

final class CountdownTimerService: CountdownTimerProtocol {

    // MARK: - Public (protocol) surface exposed via Combine

    private let timeRemainingSubject = CurrentValueSubject<Duration, Never>(.seconds(1800))
    private let isRunningSubject = CurrentValueSubject<Bool, Never>(false)

    var timeRemainingPublisher: AnyPublisher<Duration, Never> {
        timeRemainingSubject.eraseToAnyPublisher()
    }

    var isRunningPublisher: AnyPublisher<Bool, Never> {
        isRunningSubject.eraseToAnyPublisher()
    }

    var timeRemaining: Duration { timeRemainingSubject.value }
    var isRunning: Bool { isRunningSubject.value }

    // MARK: - Actor-backed state

    actor State {
        var totalDuration: Duration = .seconds(1800)
        var timeRemaining: Duration = .seconds(1800)
        var isRunning: Bool = false
        var tickingTask: Task<Void, Never>? = nil

        func cancelTask() {
            tickingTask?.cancel()
            tickingTask = nil
        }
        
        func setTickingTask(_ task: Task<Void, Never>) {
            tickingTask = task
        }
        
        func setRunning(_ running: Bool) {
            isRunning = running
        }
        
        func setTotalDuration(_ duration: Duration) {
            totalDuration = duration
        }
        
        func setTimeRemaining(_ duration: Duration) {
            timeRemaining = duration
        }
    }

    private let state = State()

    // MARK: - Lifecycle

    deinit {
        let state = self.state
        Task { await state.cancelTask() }
    }

    // MARK: - Public API (CountdownTimerProtocol)

    func start() {
        Task { [weak self] in
            guard let self else { return }

            await state.cancelTask()
            await ensureNotZeroOnStart()
            await setRunning(true)
            await startTickingTask()
        }

        #if DEBUG
        print("Timer started")
        #endif
    }

    func pause() {
        Task { [weak self] in
            guard let self else { return }
            await setRunning(false)
            await state.cancelTask()
        }

        #if DEBUG
        print("Timer paused")
        #endif
    }

    func stop() {
        Task { [weak self] in
            guard let self else { return }

            await setRunning(false)
            let total = await state.totalDuration
            await setTimeRemaining(total + .seconds(1))
            await state.cancelTask()

            #if DEBUG
            print("Timer stopped")
            #endif
        }
    }

    func reset(to duration: Duration) {
        Task { [weak self] in
            guard let self else { return }

            let wasRunning = await state.isRunning
            if wasRunning {
                await state.cancelTask()
            }

            await setTotalDuration(duration)
            await setTimeRemaining(duration)

            if wasRunning {
                await setRunning(true)
                await startTickingTask()
            }
        }

        #if DEBUG
        print("Timer reset to \(duration)")
        #endif
    }

    func format(timeRemaining: Duration) -> String {
        let totalSeconds = max(0, Int(timeRemaining.components.seconds))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Private helpers

    private func startTickingTask() async {
        await state.cancelTask()

        let tickingTask = Task { [weak self] in
            guard let self else { return }

            while !Task.isCancelled {
                // Sleep for 1 second
                try? await Task.sleep(nanoseconds: 1_000_000_000)

                // Compute new remaining
                let newRemaining: Duration = await {
                    let current = await self.state.timeRemaining
                    return current - .seconds(1)
                }()

                if newRemaining <= .zero {
                    // Hit zero: publish zero, stop, then reset remaining to total
                    await setTimeRemaining(.zero)
                    await state.cancelTask()
                    await setRunning(false)

                    let total = await state.totalDuration
                    await setTimeRemaining(total)

                    // TODO: Log Work Popup AND Notifciation Send Off AND OR Dock Icon Bounce

                    #if DEBUG
                    print("Timer reached zero")
                    #endif
                    break
                } else {
                    await setTimeRemaining(newRemaining)
                }
            }
        }
        
        await state.setTickingTask(tickingTask)
    }

    private func ensureNotZeroOnStart() async {
        let remaining = await state.timeRemaining
        if remaining <= .zero {
            let total = await state.totalDuration
            await setTimeRemaining(total)
        }
    }

    // MARK: - State mutation + publishing

    private func setRunning(_ running: Bool) async {
        await state.setRunning(running)
        await publishIsRunning(running)
    }

    private func setTotalDuration(_ duration: Duration) async {
        await state.setTotalDuration(duration)
    }

    private func setTimeRemaining(_ duration: Duration) async {
        await state.setTimeRemaining(duration)
        await publishTimeRemaining(duration)
    }

    // MARK: - Publishing on main thread

    private func publishTimeRemaining(_ value: Duration) async {
        await MainActor.run {
            timeRemainingSubject.send(value)
        }
    }

    private func publishIsRunning(_ value: Bool) async {
        await MainActor.run {
            isRunningSubject.send(value)
        }
    }
}
