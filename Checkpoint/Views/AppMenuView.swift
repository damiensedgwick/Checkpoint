//
//  AppMenuView.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 14/09/2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct AppMenuView: View {
    @ObservedObject var viewModel: AppMenuViewModel
    @ObservedObject var timerViewModel: CountdownTimerViewModel
    @Environment(\.openWindow) private var openWindow
    @State private var showingDeleteAlert = false
    
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
                viewModel.downloadAllData()
            }) {
                Label("Download Data", systemImage: "square.and.arrow.down")
            }
            
            Button(action: {
                // TODO: Dangerous, need an alert or something
                // viewModel.deleteAllLogs()
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
        .fileExporter(
            isPresented: $viewModel.showingExporter,
            document: viewModel.exportDocument,
            contentType: .commaSeparatedText,
            defaultFilename: generateDefaultFilename()
        ) { result in
            switch result {
            case .success(let url):
                print("Successfully exported to: \(url)")
            case .failure(let error):
                print("Export failed: \(error.localizedDescription)")
            }
        }
    }

    private func generateDefaultFilename() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())
        return "checkpoint-logs-\(dateString).csv"
    }
}

#Preview {
    AppMenuView(
        viewModel: AppMenuViewModel(),
        timerViewModel: CountdownTimerViewModel()
    )
}
