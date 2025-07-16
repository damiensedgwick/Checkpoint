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
    
    let intervals: [TimeInterval] = [
        15 * 60,  // 15 minutes
        30 * 60,  // 30 minutes
        45 * 60,  // 45 minutes
        60 * 60,  // 60 minutes (1 hour)
        120 * 60  // 120 minutes (2 hours)
    ]

    var body: some View {
        // Timer Status
        if dataManager.isTimerRunning {
            VStack(spacing: 4) {
                Text("Timer Running")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(timerService.formatTime(timerService.timeRemaining))
                    .font(.system(.title2, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(timerService.timeRemaining < 300 ? .red : .primary)
            }
            .padding(.vertical, 8)
            
            Divider()
            
            Button("Show Timer Window") {
                openWindow(id: "timer")
            }
            .keyboardShortcut("w", modifiers: .command)
        }
        
        // Add a new log
        Button("Log work now") {
            openWindow(id: "logging")
        }
        .keyboardShortcut("l", modifiers: .command)

        Divider()

        // Timer Controls
        if dataManager.isTimerRunning {
            Button("Stop Timer") {
                dataManager.stopTimer()
            }
            .keyboardShortcut("s", modifiers: .command)
        } else {
            Button("Start Timer") {
                dataManager.startTimer()
            }
            .keyboardShortcut("t", modifiers: .command)
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
        .keyboardShortcut("v", modifiers: .command)

        Button("Clear all logs") {
            dataManager.clearAllLogs()
        }
        .disabled(dataManager.logEntries.isEmpty)

        Divider()
        
        Button("Settings") {
            openWindow(id: "settings")
        }
        .keyboardShortcut(",", modifiers: .command)

        Divider()

        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: .command)
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
