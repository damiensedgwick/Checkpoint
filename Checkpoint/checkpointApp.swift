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
        MenuBarExtra("Checkpoint", systemImage: "hourglass") {
            MenuBarView()
        }
        .menuBarExtraStyle(.menu)

        // Timer window
        WindowGroup(id: "timer") {
            TimerWindowView()
        }
        .windowResizability(.contentSize)
        .windowStyle(.titleBar)
        .defaultSize(width: 300, height: 400)

        // Logging window
        WindowGroup(id: "logging") {
            LoggingView()
        }
        .windowResizability(.contentSize)
        .windowStyle(.titleBar)
        .defaultSize(width: 500, height: 600)

        // Logs window
        WindowGroup(id: "log-reading") {
            LogReadingView()
        }
        .windowResizability(.contentSize)
        .windowStyle(.titleBar)
        .defaultSize(width: 900, height: 600)
        
        // Settings window
        WindowGroup(id: "settings") {
            SettingsView()
        }
        .windowResizability(.contentSize)
        .windowStyle(.titleBar)
        .defaultSize(width: 400, height: 500)
    }
}
