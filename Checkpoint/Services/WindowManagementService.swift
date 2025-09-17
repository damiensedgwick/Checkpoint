//
//  WindowManagementService.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 17/09/2025.
//

import SwiftUI
import Combine
import AppKit

@MainActor
class WindowManagementService: ObservableObject {
    private var openWindowAction: OpenWindowAction?
    private var cancellables = Set<AnyCancellable>()
    private var logWorkWindowTimer: Timer?

    init() {
        setupEventSubscriptions()
    }

    func configure(openWindow: OpenWindowAction) {
        self.openWindowAction = openWindow
    }

    private func setupEventSubscriptions() {
        NotificationCenter.default
            .publisher(for: .appEvent)
            .compactMap { $0.object as? AppEventPayload }
            .sink { [weak self] payload in
                self?.handleEvent(payload.event)
            }
            .store(in: &cancellables)
    }

    private func handleEvent(_ event: AppEvent) {
        switch event {
        case .timerCompleted:
            openLogWorkWindow()
        case .workSessionEnded:
            // Handle work session completion
            break
        case .breakTimeStarted:
            // Handle break time notifications
            break
        }
    }

    private func bounceDocIcon() {
        NSApplication.shared.requestUserAttention(.criticalRequest)
    }

    private func openLogWorkWindow() {
        guard let openWindow = openWindowAction else {
            print("Window management not configured")
            return
        }

        openWindow(id: "logwork")
        bounceDocIcon()
        setLogWorkWindowFloating()
    }

    private func setLogWorkWindowFloating() {
        // Set the log work window to float temporarily
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.findAndFloatLogWorkWindow()
        }

        // Reset window level after 10 seconds or when user interacts with another app
        logWorkWindowTimer?.invalidate()
        logWorkWindowTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.resetLogWorkWindowLevel()
            }
        }

        // Listen for app deactivation to reset window level
        NotificationCenter.default
            .publisher(for: NSApplication.didResignActiveNotification)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.resetLogWorkWindowLevel()
                }
            }
            .store(in: &cancellables)
    }

    private func findAndFloatLogWorkWindow() {
        for window in NSApplication.shared.windows {
            if window.title == "Log Work" {
                window.level = .floating
                window.makeKeyAndOrderFront(nil)
                NSApplication.shared.activate(ignoringOtherApps: true)
                break
            }
        }
    }

    private func resetLogWorkWindowLevel() {
        logWorkWindowTimer?.invalidate()
        logWorkWindowTimer = nil

        for window in NSApplication.shared.windows {
            if window.title == "Log Work" && window.level == .floating {
                window.level = .normal
                break
            }
        }
    }
}