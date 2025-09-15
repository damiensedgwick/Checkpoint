//
//  AppMenuView.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 14/09/2025.
//

import SwiftUI

struct AppMenuView: View {
    @StateObject private var viewModel: AppMenuViewModel

    init(dataManager: DataManager) {
        _viewModel = StateObject(wrappedValue: AppMenuViewModel(dataManager: dataManager))
    }

    var body: some View {
        Button(action: {
            // TODO:
        }) {
            Label("About Checkpoint", systemImage: "info.circle")
        }

        Divider()

        Button(action: {
            // TODO:
        }) {
            Label("Add Log", systemImage: "plus")
        }

        Button(action: {
            // TODO:
        }) {
            Label("View Logs", systemImage: "list.dash")
        }

        Divider()

        Button(action: {
            // TODO:
        }) {
            Label("Start Timer", systemImage: "play.fill")
        }

        Button(action: {
            // TODO:
        }) {
            Label("Pause Timer", systemImage: "pause.fill")
        }

        Button(action: {
            // TODO:
        }) {
            Label("Stop Timer", systemImage: "stop.fill")
        }

        Divider()

        Menu {
            ForEach(viewModel.intervals, id: \.id) { interval in
                Button(action: {
                    viewModel.selectInterval(withID: interval.id)
                    #if DEBUG
                    print("Selected interval: \(interval.label)")
                    #endif // DEBUG
                }) {
                    HStack {
                        Text(interval.label)
                        Spacer()
                        if interval.isSelected {
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
            Label("Settings", systemImage: "gear")
        }

        Divider()

        Button(action: {
            // TODO:
        }) {
            Label("Quit Checkpoint", systemImage: "xmark.circle")
        }
    }
}

#Preview {
    AppMenuView(dataManager: DataManager())
}
