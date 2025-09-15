//
//  CheckpointApp.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 14/09/2025.
//

import SwiftUI

@main
struct CheckpointApp: App {
    @StateObject private var viewModel = AppMenuViewModel()

    var body: some Scene {
        MenuBarExtra("Checkpoint", systemImage: "hourglass") {
            AppMenuView(viewModel: viewModel)
        }
    }
}
