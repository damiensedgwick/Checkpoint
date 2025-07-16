//
//  checkpointApp.swift
//  checkpoint
//
//  Created by Damien Sedgwick on 05/07/2025.
//

import SwiftUI

@main
struct checkpointApp: App {
    @State private var currentInterval: TimeInterval = 30 * 60 // default interval is 30 minutes, if the user changes this, save it in a config?

    let intervals: [TimeInterval] = [
        15 * 60,  // 15 minutes
        30 * 60,  // 30 minutes
        45 * 60,  // 45 minutes
        60 * 60,  // 60 minutes (1 hour)
        120 * 60  // 120 minutes (2 hours)
    ]

    func changeInterval(_ interval: TimeInterval) {
        self.currentInterval = interval
    }

    var body: some Scene {
        // Menu bar controls
        MenuBarExtra("Checkpoint", systemImage: "hourglass") {
            MenuBarView(
                currentInterval: $currentInterval,
                intervals: intervals,
                changeInterval: changeInterval
            )
        }
        .menuBarExtraStyle(.menu)

        // Logs window
        WindowGroup(id: "log-reading") {
            LogReadingView()
        }
        .windowResizability(.contentSize)
        .windowStyle(.titleBar)
    }
}
