//
//  MenuBarView.swift
//  checkpoint
//
//  Created by Damien Sedgwick on 05/07/2025.
//

import SwiftUI

struct MenuBarView: View {
    @Environment(\.openWindow) private var openWindow
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var timerService = TimerService.shared
    @StateObject private var windowService = WindowService.shared
    
    var intervals: [TimeInterval] {
        var baseIntervals: [TimeInterval] = [
            15 * 60,  // 15 minutes
            30 * 60,  // 30 minutes
            45 * 60,  // 45 minutes
            60 * 60,  // 60 minutes (1 hour)
            120 * 60  // 120 minutes (2 hours)
        ]
        
        #if DEBUG
        // Add 1-minute interval for testing only
        baseIntervals.insert(60, at: 0)  // 1 minute
        #endif
        
        return baseIntervals
    }

    var body: some View {
        // Add a new log
        Button("Log work now") {
            openWindow(id: "logging")
            // Bring the window to the front after a brief delay to ensure it's created
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                windowService.bringLoggingWindowToFront()
            }
        }

        Divider()

        // Timer Controls
        if dataManager.isTimerRunning {
            Button("Stop Timer") {
                dataManager.stopTimer()
            }
        } else {
            Button("Start Timer") {
                dataManager.startTimer()
            }
        }

        Divider()

        // Interval selection submenu
        Menu("Set Interval") {
            ForEach(intervals, id: \.self) { interval in
                Button(action: {
                    dataManager.updateInterval(interval)
                }) {
                    Text(interval == dataManager.currentInterval ?
                         "\(formatInterval(interval)) ✓" :
                            formatInterval(interval))
                }
            }
        }

        Divider()

        Button("View logs") {
            openWindow(id: "log-reading")
        }

        Divider()
        
        Button("Settings") {
            openWindow(id: "settings")
        }

        Divider()

        Button("Quit") {
            // Stop the timer and clear persisted state before quitting
            dataManager.stopTimerAndClear()
            NSApplication.shared.terminate(nil)
        }
    }

    // Helper function to format time intervals
    private func formatInterval(_ interval: TimeInterval) -> String {
        let minutes = Int(interval / 60)
        if minutes >= 60 {
            let hours = minutes / 60
            return "\(hours) hour\(hours == 1 ? "" : "s")"
        } else {
            return "\(minutes) min\(minutes == 1 ? "" : "s")"
        }
    }
}

#Preview {
    MenuBarView()
}
