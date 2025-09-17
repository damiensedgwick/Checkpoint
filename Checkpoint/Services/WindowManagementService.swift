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
    }
}