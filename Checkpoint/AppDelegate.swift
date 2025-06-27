//
//  AppDelegate.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 27/06/2025.
//

import Cocoa
import SQLite3

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var timer: Timer?
    var database: OpaquePointer?
    var intervalMinutes: Int = 60 // Default to 60 minutes

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Hide dock icon - run as menu bar only app
        NSApp.setActivationPolicy(.accessory)

        // Setup status bar
        setupStatusBar()

        // Initialize database
        initializeDatabase()

        // Start timer
        startTimer()
    }

    func setupStatusBar() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: "clock.arrow.circlepath", accessibilityDescription: "Work Logger")
        }

        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "Log Work Now", action: #selector(showLogWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())

        let intervalMenu = NSMenuItem(title: "Set Interval", action: nil, keyEquivalent: "")
        let intervalSubmenu = NSMenu()

        let intervals = [15, 30, 45, 60, 90, 120] // minutes
        for interval in intervals {
            let item = NSMenuItem(title: "\(interval) minutes", action: #selector(setInterval(_:)), keyEquivalent: "")
            item.tag = interval
            if interval == intervalMinutes {
                item.state = .on
            }
            intervalSubmenu.addItem(item)
        }

        intervalMenu.submenu = intervalSubmenu
        menu.addItem(intervalMenu)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "View Logs", action: #selector(showLogs), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusBarItem.menu = menu
    }

    func initializeDatabase() {
        let fileURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("WorkLogger")

        try! FileManager.default.createDirectory(at: fileURL, withIntermediateDirectories: true)

        let dbPath = fileURL.appendingPathComponent("work_logs.sqlite").path

        if sqlite3_open(dbPath, &database) == SQLITE_OK {
            let createTableSQL = """
                CREATE TABLE IF NOT EXISTS work_logs (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    timestamp TEXT NOT NULL,
                    project TEXT NOT NULL,
                    description TEXT NOT NULL
                );
            """

            if sqlite3_exec(database, createTableSQL, nil, nil, nil) != SQLITE_OK {
                print("Unable to create table")
            }
        } else {
            print("Unable to open database")
        }
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(intervalMinutes * 60), repeats: true) { _ in
            self.showLogWindow()
        }
    }

    @objc func setInterval(_ sender: NSMenuItem) {
        intervalMinutes = sender.tag

        // Update menu checkmarks
        if let intervalMenu = statusBarItem.menu?.item(withTitle: "Set Interval"),
           let submenu = intervalMenu.submenu {
            for item in submenu.items {
                item.state = (item.tag == intervalMinutes) ? .on : .off
            }
        }

        // Restart timer with new interval
        startTimer()
    }

    @objc func showLogWindow() {
        DispatchQueue.main.async {
            let logWindow = LogWindow()
            logWindow.delegate = self
            logWindow.showWindow()
        }
    }

    @objc func showLogs() {
        let logsWindow = LogsWindow(database: database)
        logsWindow.showWindow()
    }

    func saveLog(project: String, description: String) {
        let insertSQL = "INSERT INTO work_logs (timestamp, project, description) VALUES (?, ?, ?)"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(database, insertSQL, -1, &statement, nil) == SQLITE_OK {
            let timestamp = ISO8601DateFormatter().string(from: Date())

            sqlite3_bind_text(statement, 1, timestamp, -1, nil)
            sqlite3_bind_text(statement, 2, project, -1, nil)
            sqlite3_bind_text(statement, 3, description, -1, nil)

            if sqlite3_step(statement) == SQLITE_DONE {
                print("Log saved successfully")
            } else {
                print("Could not save log")
            }
        }

        sqlite3_finalize(statement)
    }
}

// MARK: - Log Window
class LogWindow: NSObject, NSWindowDelegate {
    var window: NSWindow!
    var projectField: NSTextField!
    var descriptionField: NSTextView!
    var delegate: AppDelegate?

    func showWindow() {
        // Create window
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )

        window.title = "Log Your Work"
        window.delegate = self
        window.level = .floating
        window.center()

        setupUI()

        // Make window key and bring to front
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    func setupUI() {
        let contentView = NSView(frame: window.contentRect(forFrameRect: window.frame))
        window.contentView = contentView

        // Project label and field
        let projectLabel = NSTextField(labelWithString: "Project:")
        projectLabel.frame = NSRect(x: 20, y: 240, width: 60, height: 20)
        contentView.addSubview(projectLabel)

        projectField = NSTextField(frame: NSRect(x: 90, y: 240, width: 290, height: 22))
        projectField.placeholderString = "Enter project name"
        contentView.addSubview(projectField)

        // Description label and field
        let descriptionLabel = NSTextField(labelWithString: "What did you work on?")
        descriptionLabel.frame = NSRect(x: 20, y: 200, width: 360, height: 20)
        contentView.addSubview(descriptionLabel)

        let scrollView = NSScrollView(frame: NSRect(x: 20, y: 80, width: 360, height: 100))
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = false

        descriptionField = NSTextView(frame: scrollView.contentView.bounds)
        descriptionField.isRichText = false
        descriptionField.font = NSFont.systemFont(ofSize: 13)

        scrollView.documentView = descriptionField
        contentView.addSubview(scrollView)

        // Save button
        let saveButton = NSButton(frame: NSRect(x: 310, y: 20, width: 70, height: 32))
        saveButton.title = "Save"
        saveButton.bezelStyle = .rounded
        saveButton.keyEquivalent = "\r"
        saveButton.target = self
        saveButton.action = #selector(saveLog)
        contentView.addSubview(saveButton)

        // Set focus to project field
        window.makeFirstResponder(projectField)
    }

    @objc func saveLog() {
        let project = projectField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let description = descriptionField.string.trimmingCharacters(in: .whitespacesAndNewlines)

        if project.isEmpty || description.isEmpty {
            let alert = NSAlert()
            alert.messageText = "Missing Information"
            alert.informativeText = "Please fill in both project and description fields."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
            return
        }

        delegate?.saveLog(project: project, description: description)
        window.close()
    }

    // Prevent window from closing without saving
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        let project = projectField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let description = descriptionField.string.trimmingCharacters(in: .whitespacesAndNewlines)

        if !project.isEmpty || !description.isEmpty {
            let alert = NSAlert()
            alert.messageText = "Unsaved Changes"
            alert.informativeText = "You have unsaved work. Are you sure you want to close without saving?"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Save")
            alert.addButton(withTitle: "Don't Save")
            alert.addButton(withTitle: "Cancel")

            let response = alert.runModal()
            switch response {
            case .alertFirstButtonReturn: // Save
                saveLog()
                return false // saveLog will close the window if successful
            case .alertSecondButtonReturn: // Don't Save
                return true
            default: // Cancel
                return false
            }
        }

        return true
    }
}

// MARK: - Logs Viewer Window
class LogsWindow: NSObject, NSWindowDelegate, NSTableViewDataSource, NSTableViewDelegate {
    var window: NSWindow!
    var tableView: NSTableView!
    var database: OpaquePointer?
    var logs: [(id: Int, timestamp: String, project: String, description: String)] = []

    init(database: OpaquePointer?) {
        self.database = database
        super.init()
        loadLogs()
    }

    func showWindow() {
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.title = "Work Logs"
        window.delegate = self
        window.center()

        setupUI()
        window.makeKeyAndOrderFront(nil)
    }

    func setupUI() {
        let contentView = NSView(frame: window.contentRect(forFrameRect: window.frame))
        window.contentView = contentView

        let scrollView = NSScrollView(frame: contentView.bounds)
        scrollView.autoresizingMask = [.width, .height]
        scrollView.hasVerticalScroller = true

        tableView = NSTableView()
        tableView.dataSource = self
        tableView.delegate = self

        // Create columns
        let timestampColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("timestamp"))
        timestampColumn.title = "Time"
        timestampColumn.width = 150
        tableView.addTableColumn(timestampColumn)

        let projectColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("project"))
        projectColumn.title = "Project"
        projectColumn.width = 150
        tableView.addTableColumn(projectColumn)

        let descriptionColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("description"))
        descriptionColumn.title = "Description"
        descriptionColumn.width = 400
        tableView.addTableColumn(descriptionColumn)

        scrollView.documentView = tableView
        contentView.addSubview(scrollView)
    }

    func loadLogs() {
        logs.removeAll()

        let querySQL = "SELECT id, timestamp, project, description FROM work_logs ORDER BY timestamp DESC"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(database, querySQL, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int(statement, 0)
                let timestamp = String(cString: sqlite3_column_text(statement, 1))
                let project = String(cString: sqlite3_column_text(statement, 2))
                let description = String(cString: sqlite3_column_text(statement, 3))

                logs.append((id: Int(id), timestamp: timestamp, project: project, description: description))
            }
        }

        sqlite3_finalize(statement)
        tableView?.reloadData()
    }

    // MARK: - Table View Data Source
    func numberOfRows(in tableView: NSTableView) -> Int {
        return logs.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let log = logs[row]

        switch tableColumn?.identifier.rawValue {
        case "timestamp":
            let formatter = ISO8601DateFormatter()
            if let date = formatter.date(from: log.timestamp) {
                let displayFormatter = DateFormatter()
                displayFormatter.dateStyle = .short
                displayFormatter.timeStyle = .short
                return displayFormatter.string(from: date)
            }
            return log.timestamp
        case "project":
            return log.project
        case "description":
            return log.description
        default:
            return nil
        }
    }
}
