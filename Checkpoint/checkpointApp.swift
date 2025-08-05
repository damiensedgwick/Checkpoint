//
//  checkpointApp.swift
//  checkpoint
//
//  Created by Damien Sedgwick on 05/07/2025.
//

import SwiftUI

struct TimerLabelView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var timerService = TimerService.shared
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "hourglass")
                .frame(width: 50)
            if timerService.timeRemaining > 0 {
                Text(timerService.formatTime(timerService.timeRemaining))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(timerService.timeRemaining < 300 ? .red : .primary)
                    .frame(width: 50, alignment: .leading) // Fixed width for "00:00" format
            }
        }
        .frame(width: 125)
    }
}

@main
struct checkpointApp: App {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var timerService = TimerService.shared
    @StateObject private var windowService = WindowService.shared
    @Environment(\.openWindow) private var openWindow
    
    init() {
        // Set up app termination handler to stop timer when app is closed
        NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { _ in
            DataManager.shared.stopTimerAndClear()
        }
    }
    
    var body: some Scene {
        // Menu bar controls
        MenuBarExtra {
            MenuBarView()
        } label: {
            TimerLabelView()
        }
        .menuBarExtraStyle(.menu)

        // Logging window
        WindowGroup(id: "logging") {
            LoggingView()
        }
        .windowResizability(.contentSize)
        .windowStyle(.titleBar)
        .defaultSize(width: 350, height: 280)
        .onChange(of: windowService.shouldOpenLoggingWindow) { oldValue, shouldOpen in
            if shouldOpen {
                openWindow(id: "logging")
                // Bring the window to the front after a brief delay to ensure it's created
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    windowService.bringLoggingWindowToFront()
                }
                windowService.shouldOpenLoggingWindow = false
            }
        }

        // Logs window
        WindowGroup(id: "log-reading") {
            LogReadingView()
        }
        .windowResizability(.contentSize)
        .windowStyle(.titleBar)
        .defaultSize(width: 700, height: 400)
        
        // Settings window
        WindowGroup(id: "settings") {
            SettingsView()
        }
        .windowResizability(.contentSize)
        .windowStyle(.titleBar)
        .defaultSize(width: 400, height: 500)
    }
}


