//
//  checkpointApp.swift
//  checkpoint
//
//  Created by Damien Sedgwick on 05/07/2025.
//

import SwiftUI

@main
struct checkpointApp: App {
    var body: some Scene {
        // Hide the main window (we'll control everything from menubar)
        WindowGroup {
            EmptyView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)

        // Logging window
        WindowGroup("Logging", id: "logging") {
            LoggingView()
        }
        .windowResizability(.contentSize)

        // Log reading window
        WindowGroup("Log Reading", id: "log-reading") {
            LogReadingView()
        }
        .windowResizability(.contentSize)

        // Menu bar controls
        MenuBarExtra("Checkpoint", systemImage: "checkmark.circle") {
            MenuBarView()
        }
        .menuBarExtraStyle(.window)
    }
}
