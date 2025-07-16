//
//  checkpointApp.swift
//  checkpoint
//
//  Created by Damien Sedgwick on 05/07/2025.
//

import SwiftUI

@main
struct checkpointApp: App {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var timerService = TimerService.shared

    var body: some Scene {
        // Menu bar controls
        MenuBarExtra {
            MenuBarView()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "hourglass")
                if dataManager.isTimerRunning {
                    // Fixed width for timer text to prevent wiggle
                    Text(timerService.formatTime(timerService.timeRemaining))
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(timerService.timeRemaining < 300 ? .red : .primary)
                        .frame(width: 38, alignment: .trailing) // "00:00" is 5 chars, 38 is a good width for monospaced caption
                }
            }
        }
        .menuBarExtraStyle(.window)



        // Logging window
        WindowGroup(id: "logging") {
            LoggingView()
        }
        .windowResizability(.contentSize)
        .windowStyle(.titleBar)
        .defaultSize(width: 350, height: 280)

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
