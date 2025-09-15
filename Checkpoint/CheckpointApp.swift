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
        } label: {
            CountdownTimerView(viewModel: countdownTimerViewModel)
        }
    }
}
