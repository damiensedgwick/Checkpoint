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

    // Backing subjects to emit changes to observers.
    private let timeRemainingSubject = CurrentValueSubject<Duration, Never>(.seconds(1800))
    private let isRunningSubject = CurrentValueSubject<Bool, Never>(false)

    // Public publisher required by the protocol.
    var timeRemainingPublisher: AnyPublisher<Duration, Never> {
        timeRemainingSubject.eraseToAnyPublisher()
    }

    // Protocol properties read from subjects.
    var timeRemaining: Duration { timeRemainingSubject.value }
    var isRunning: Bool { isRunningSubject.value }

    // MARK: - Actor-backed state

    // Inner actor to hold mutable state safely and drive the ticking loop.
    private actor State {
        var totalDuration: Duration = .seconds(1800)
        var timeRemaining: Duration = .seconds(1800)
        var isRunning: Bool = false
        var tickingTask: Task<Void, Never>? = nil

        func cancelTask() {
            tickingTask?.cancel()
            tickingTask = nil
        }
    }

    private let state = State()

    // MARK: - Lifecycle

    deinit {
        Task { await state.cancelTask() }
    }

    // MARK: - Public API (CountdownTimerProtocol)

    func start() {
        Task { [weak self] in
            guard let self else { return }

            await state.cancelTask()

            // If already at zero, reset to totalDuration before starting.
            await self.ensureNotZeroOnStart()

            // Mark running in state and publish.
            await self.setRunning(true)

            // Create ticking task.
            await self.startTickingTask()
        }

        #if DEBUG
        print("Timer started")
        #endif
    }

    func pause() {
        Task { [weak self] in
            guard let self else { return }

            await state.cancelTask()
            await setRunning(false)
        }

        #if DEBUG
        print("Timer paused")
        #endif
    }

    func stop() {
        Task { [weak self] in
            guard let self else { return }

            await state.cancelTask()

            // Reset remaining to total and publish, mark not running.
            let total = await state.totalDuration
            await setTimeRemaining(total)
            await setRunning(false)
        }

        #if DEBUG
        print("Timer stopped and reset")
        #endif
    }

    func reset(to duration: Duration) {
        Task { [weak self] in
            guard let self else { return }

            // Preserve running state
            let wasRunning = await state.isRunning

            // Stop ticking if running
            if wasRunning {
                await state.cancelTask()
            }

            // Update durations
            await setTotalDuration(duration)
            await setTimeRemaining(duration)

            // Resume if it was running
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

        state.tickingTask = Task { [weak self] in
            guard let self else { return }
            // Tick every 1 second using Swift Concurrency.
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)

                // Decrement remaining time
                let newRemaining: Duration = await {
                    let current = await state.timeRemaining
                    return current - .seconds(1)
                }()

                if newRemaining <= .zero {
                    // Publish zero, stop and reset to total
                    await setTimeRemaining(.zero)
                    await state.cancelTask()
                    await setRunning(false)

                    // Reset to total (stop semantics already handle this in stop(), but here we emulate current behavior)
                    let total = await state.totalDuration
                    await setTimeRemaining(total)

                    #if DEBUG
                    print("Timer reached zero")
                    #endif
                    break
                } else {
                    await setTimeRemaining(newRemaining)
                }
            }
        }
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
        await state.set(\.isRunning, to: running)
        publishIsRunning(running)
    }

    private func setTotalDuration(_ duration: Duration) async {
        await state.set(\.totalDuration, to: duration)
    }

    private func setTimeRemaining(_ duration: Duration) async {
        await state.set(\.timeRemaining, to: duration)
        publishTimeRemaining(duration)
    }

    // MARK: - Publishing on main thread

    private func publishTimeRemaining(_ value: Duration) {
        if Thread.isMainThread {
            timeRemainingSubject.send(value)
        } else {
            DispatchQueue.main.async { [timeRemainingSubject] in
                timeRemainingSubject.send(value)
            }
        }
    }

    private func publishIsRunning(_ value: Bool) {
        if Thread.isMainThread {
            isRunningSubject.send(value)
        } else {
            DispatchQueue.main.async { [isRunningSubject] in
                isRunningSubject.send(value)
            }
        }
    }
}

// MARK: - Small convenience to mutate actor properties by key path
private extension CountdownTimerService.State {
    func set<Value>(_ keyPath: WritableKeyPath<CountdownTimerService.State, Value>, to newValue: Value) {
        self[keyPath: keyPath] = newValue
    }
}
