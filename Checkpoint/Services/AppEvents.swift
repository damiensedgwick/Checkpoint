//
//  AppEvents.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 17/09/2025.
//

import Foundation

enum AppEvent {
    case timerCompleted
    case workSessionEnded(duration: Duration)
    case breakTimeStarted
}

extension Notification.Name {
    static let appEvent = Notification.Name("AppEvent")
}

struct AppEventPayload {
    let event: AppEvent
    let timestamp: Date

    init(_ event: AppEvent) {
        self.event = event
        self.timestamp = Date()
    }
}

class AppEventPublisher {
    static let shared = AppEventPublisher()
    private init() {}

    func publish(_ event: AppEvent) {
        NotificationCenter.default.post(
            name: .appEvent,
            object: AppEventPayload(event)
        )
    }
}