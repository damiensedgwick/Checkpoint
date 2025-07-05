//
//  MenuBarView.swift
//  checkpoint
//
//  Created by Damien Sedgwick on 05/07/2025.
//

import SwiftUI

struct MenuBarView: View {
    @Environment(\.openWindow) private var openWindow
    @Binding var currentInterval: TimeInterval
    let intervals: [TimeInterval]
    let changeInterval: (TimeInterval) -> Void

    var body: some View {
        // Add a new log
        Button("Log work now") {
            // openWindow(id: "logging")
        }

        Divider()

        // Interval selection submenu
        Menu("Set Interval") {
            ForEach(intervals, id: \.self) { interval in
                Button(action: {
                    changeInterval(interval)
                }) {
                    Text(interval == currentInterval ?
                         "\(formatInterval(interval)) ✓" :
                            formatInterval(interval))
                }
            }
        }

        Divider()


        Button("View logs") {
            // openWindow(id: "log-reading")
        }

        Button("Clear all logs") {
            // openWindow(id: "log-reading")
        }

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
    MenuBarView(
        currentInterval: .constant(30 * 60),
        intervals: [15 * 60, 30 * 60, 45 * 60, 60 * 60, 120 * 60],
        changeInterval: { _ in }
    )
}
