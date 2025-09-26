//
//  AppMenuView.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 14/09/2025.
//

import SwiftUI

struct AppMenuView: View {
    @ObservedObject var viewModel: AppMenuViewModel
    @ObservedObject var timerViewModel: CountdownTimerViewModel
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack {
            Button(action: {
                // TODO:
            }) {
                Label("Launch At Login", systemImage: "autostartstop")
            }
            
            Divider()
            
            Button(action: {
                openWindow(id: "logwork")
            }) {
                Label("Add Log", systemImage: "plus")
            }
            
            Button(action: {
                openWindow(id: "viewlogs")
            }) {
                Label("View Logs", systemImage: "list.dash")
            }
            
            Divider()
            
            Button(action: {
                timerViewModel.start()
            }) {
                Label("Start Timer", systemImage: "play.fill")
            }
            .disabled(timerViewModel.isRunning)
            
            Button(action: {
                timerViewModel.pause()
            }) {
                Label("Pause Timer", systemImage: "pause.fill")
            }
            .disabled(!timerViewModel.isRunning)
            
            Button(action: {
                timerViewModel.stop()
            }) {
                Label("Stop Timer", systemImage: "stop.fill")
            }
            
            Divider()
            
            Menu {
                ForEach(viewModel.intervals, id: \.id) { interval in
                    Button(action: {
                        viewModel.selectInterval(withID: interval.id)
                        timerViewModel.reset(to: interval.duration)
                    }) {
                        HStack {
                            Text(interval.label)
                            Spacer()
                            if viewModel.isIntervalSelected(interval) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Label("Change Interval", systemImage: "clock")
            }
            
            Divider()
            
            Button(action: {
                // TODO:
            }) {
                Label("Download Data", systemImage: "square.and.arrow.down")
            }
            
            Button(action: {
                // TODO:
            }) {
                Label("Delete All Logs", systemImage: "trash")
            }
            
            Divider()
            
            Button(action: {
                openWindow(id: "about")
            }) {
                Label("About Checkpoint", systemImage: "info.circle")
            }
            
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Label("Quit Checkpoint", systemImage: "xmark.circle")
            }
        }
    }
}

#Preview {
    AppMenuView(
        viewModel: AppMenuViewModel(),
        timerViewModel: CountdownTimerViewModel()
    )
}
