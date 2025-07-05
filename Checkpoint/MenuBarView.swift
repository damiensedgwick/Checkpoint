//
//  MenuBarView.swift
//  checkpoint
//
//  Created by Damien Sedgwick on 05/07/2025.
//

import SwiftUI

struct MenuBarView: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack {
            Button("Open Logging Window") {
                openWindow(id: "logging")
            }

            Button("Open Log Reading Window") {
                openWindow(id: "log-reading")
            }

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
    }
}

#Preview {
    MenuBarView()
}
