//
//  CheckpointApp.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 14/09/2025.
//

import SwiftUI

@main
struct CheckpointApp: App {
    @StateObject private var appViewModel: AppMenuViewModel
    @StateObject private var countdownTimerViewModel: CountdownTimerViewModel
    @StateObject private var windowManager = WindowManagementService()
    @Environment(\.openWindow) private var openWindow

    init() {
        let service = CountdownTimerService()
        let menuViewModel = AppMenuViewModel()

        if let defaultInterval = menuViewModel.intervals.first(where: { $0.id == menuViewModel.selectedIntervalId }) {
            service.reset(to: defaultInterval.duration)
        }

        _appViewModel = StateObject(wrappedValue: menuViewModel)
        _countdownTimerViewModel = StateObject(wrappedValue: CountdownTimerViewModel(countdownTimerService: service))
    }

    var body: some Scene {
        MenuBarExtra {
            AppMenuView(
                viewModel: appViewModel,
                timerViewModel: countdownTimerViewModel
            )
            .onAppear {
                windowManager.configure(openWindow: openWindow)
            }
        } label: {
            CountdownTimerView(viewModel: countdownTimerViewModel)
        }

        Window("About Checkpoint", id: "about") {
            AboutWindowView()
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .defaultPosition(.center)

        Window("Log Work", id: "logwork") {
            LogWorkView()
        }
        .windowStyle(.hiddenTitleBar)
        .defaultPosition(.center)

        Window("View Work Logs", id: "viewlogs") {
            ViewWorkLogsView()
        }
        .windowStyle(.hiddenTitleBar)
        .defaultPosition(.center)
    }
}
