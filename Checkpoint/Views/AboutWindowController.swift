//
//  AboutWindowController.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 15/09/2025.
//

import Cocoa
import SwiftUI

class AboutWindowController: NSWindowController {
    static let shared = AboutWindowController()

    private init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 300),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("AboutWindow")

        super.init(window: window)

        let aboutView = AboutView {
            self.close()
        }
        window.contentView = NSHostingView(rootView: aboutView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showWindow() {
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
