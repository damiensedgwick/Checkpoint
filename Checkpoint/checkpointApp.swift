//
//  checkpointApp.swift
//  checkpoint
//
//  Created by Damien Sedgwick on 13/09/2025.
//

import SwiftUI

@main
struct checkpointApp: App {
    var body: some Scene {
        WindowGroup("Checkpoint") {
            LogWorkView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
