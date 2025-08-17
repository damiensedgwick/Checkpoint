//
//  MenuBarView.swift
//  checkpoint
//
//  Created by Damien Sedgwick on 05/07/2025.
//

import SwiftUI

struct MenuBarView: View {
    @Environment(\.openWindow) private var openWindow
    @StateObject private var viewModel = MenuBarViewModel(
        dataManager: DataManager.shared,
        windowService: WindowService.shared
    )
    
    var body: some View {
        // Add a new log
        Button("Log work now") {
            viewModel.openLoggingWindow()
        }

        Divider()

        // Timer Controls
        if viewModel.isTimerRunning {
            Button("Stop Timer") {
                viewModel.toggleTimer()
            }
            
            if !viewModel.isLoggingWindowOpen {
                Button(viewModel.isTimerPaused ? "Resume Timer" : "Pause Timer") {
                    viewModel.togglePauseTimer()
                }
            }
        } else {
            Button("Start Timer") {
                viewModel.toggleTimer()
            }
            .disabled(viewModel.isLoggingWindowOpen)
        }

        Divider()

        // Interval selection submenu
        Menu("Set Interval") {
            ForEach(viewModel.intervals, id: \.self) { interval in
                Button(action: {
                    viewModel.updateInterval(interval)
                }) {
                    Text(viewModel.isCurrentInterval(interval) ?
                         "\(viewModel.formatInterval(interval)) ✓" :
                            viewModel.formatInterval(interval))
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
            viewModel.quitApp()
        }
    }
}

#Preview {
    MenuBarView()
}
