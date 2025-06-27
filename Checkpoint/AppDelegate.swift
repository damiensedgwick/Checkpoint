import Cocoa
import SQLite3

protocol LogWindowDelegate: AnyObject {
    func saveLog(project: String, description: String)
}

class AppDelegate: NSObject, NSApplicationDelegate, LogWindowDelegate {
    var statusBarItem: NSStatusItem!
    var timer: Timer?
    var database: OpaquePointer?
    var intervalMinutes: Int = 60 // Default to 60 minutes
    var currentLogWindow: LogWindow? // Keep strong reference
    var currentLogsWindow: LogsWindow? // Keep strong reference

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

        let intervals = [1, 15, 30, 45, 60, 90, 120] // minutes
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
        menu.addItem(NSMenuItem(title: "Clear All Logs", action: #selector(clearAllLogs), keyEquivalent: ""))
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
            // Dismiss existing window if any
            self.currentLogWindow?.window?.close()

            let logWindow = LogWindow()
            logWindow.delegate = self
            self.currentLogWindow = logWindow // Keep strong reference
            logWindow.showWindow()
        }
    }

    @objc func showLogs() {
        // Close existing logs window if any
        currentLogsWindow?.window?.close()

        let logsWindow = LogsWindow(database: database)
        currentLogsWindow = logsWindow // Keep strong reference
        logsWindow.showWindow()
    }

    @objc func clearAllLogs() {
        let alert = NSAlert()
        alert.messageText = "Clear All Logs"
        alert.informativeText = "Are you sure you want to delete all work logs? This cannot be undone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Delete All")
        alert.addButton(withTitle: "Cancel")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            let deleteSQL = "DELETE FROM work_logs"
            if sqlite3_exec(database, deleteSQL, nil, nil, nil) == SQLITE_OK {
                print("All logs cleared successfully")

                // Refresh the logs window if it's open
                currentLogsWindow?.loadLogs()
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(database))
                print("Could not clear logs: \(errorMessage)")
            }
        }
    }

    func saveLog(project: String, description: String) {
        print("AppDelegate saveLog called with project: '\(project)', description: '\(description)'")
        print("String lengths - project: \(project.count), description: \(description.count)")

        let insertSQL = "INSERT INTO work_logs (timestamp, project, description) VALUES (?, ?, ?)"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(database, insertSQL, -1, &statement, nil) == SQLITE_OK {
            let timestamp = ISO8601DateFormatter().string(from: Date())
            print("Generated timestamp: '\(timestamp)' (length: \(timestamp.count))")

            // Use a simpler approach - let Swift handle the C string conversion
            let timestampCString = timestamp.cString(using: .utf8)!
            let projectCString = project.cString(using: .utf8)!
            let descriptionCString = description.cString(using: .utf8)!

            // Bind with explicit lengths and SQLITE_TRANSIENT
            sqlite3_bind_text(statement, 1, timestampCString, Int32(timestampCString.count - 1), unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_text(statement, 2, projectCString, Int32(projectCString.count - 1), unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_text(statement, 3, descriptionCString, Int32(descriptionCString.count - 1), unsafeBitCast(-1, to: sqlite3_destructor_type.self))

            print("About to execute insert statement")
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Log saved successfully to database")

                // Debug: Verify the data was actually saved
                let verifySQL = "SELECT timestamp, project, description FROM work_logs WHERE id = last_insert_rowid()"
                var verifyStatement: OpaquePointer?

                if sqlite3_prepare_v2(database, verifySQL, -1, &verifyStatement, nil) == SQLITE_OK {
                    if sqlite3_step(verifyStatement) == SQLITE_ROW {
                        // Use our safe string extraction method
                        let savedTimestamp = stringFromSQLite(verifyStatement, 0)
                        let savedProject = stringFromSQLite(verifyStatement, 1)
                        let savedDescription = stringFromSQLite(verifyStatement, 2)
                        print("Verified saved data - timestamp: '\(savedTimestamp)', project: '\(savedProject)', description: '\(savedDescription)'")
                    }
                }
                sqlite3_finalize(verifyStatement)

            } else {
                let errorMessage = String(cString: sqlite3_errmsg(database))
                print("Could not save log to database: \(errorMessage)")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(database))
            print("Could not prepare SQL statement: \(errorMessage)")
        }

        sqlite3_finalize(statement)
    }

    // Helper method for safe string extraction - moved here so saveLog can use it too
    func stringFromSQLite(_ statement: OpaquePointer?, _ index: Int32) -> String {
        guard let statement = statement else {
            print("Statement is nil for column \(index)")
            return ""
        }

        // Check if the column is NULL
        if sqlite3_column_type(statement, index) == SQLITE_NULL {
            print("Column \(index) is NULL")
            return ""
        }

        // Get the text - sqlite3_column_text returns a pointer to UTF-8 text
        guard let cString = sqlite3_column_text(statement, index) else {
            print("Column \(index) returned NULL pointer")
            return ""
        }

        let result = String(cString: cString)
        print("Column \(index) value: '\(result)'")
        return result
    }
}

// MARK: - Log Window
class LogWindow: NSObject, NSWindowDelegate {
    var window: NSWindow!
    var projectField: NSTextField!
    var descriptionField: NSTextView!
    weak var delegate: LogWindowDelegate?

    func showWindow() {
        print("LogWindow showWindow called")

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

        // Keep a strong reference to prevent deallocation
        window.isReleasedWhenClosed = false

        setupUI()

        print("Delegate set to: \(String(describing: delegate))")

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

        // Save button - explicit target/action setup
        let saveButton = NSButton(frame: NSRect(x: 310, y: 20, width: 70, height: 32))
        saveButton.title = "Save"
        saveButton.bezelStyle = .rounded
        saveButton.keyEquivalent = "\r"

        // Debug: Print to verify button creation
        print("Creating save button with target: \(self)")

        // Set target and action explicitly
        saveButton.target = self
        saveButton.action = #selector(LogWindow.saveLog)

        contentView.addSubview(saveButton)

        // Set focus to project field
        window.makeFirstResponder(projectField)
    }

    @objc func saveLog() {
        print("Save button clicked!")

        let project = projectField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let description = descriptionField.string.trimmingCharacters(in: .whitespacesAndNewlines)

        print("Save button clicked - Project: '\(project)', Description: '\(description)'")

        if project.isEmpty || description.isEmpty {
            let alert = NSAlert()
            alert.messageText = "Missing Information"
            alert.informativeText = "Please fill in both project and description fields."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
            return
        }

        print("Calling delegate to save log")
        delegate?.saveLog(project: project, description: description)

        print("Closing window")
        window.close()

        // Clear the reference in the app delegate
        if let appDelegate = delegate as? AppDelegate {
            appDelegate.currentLogWindow = nil
        }
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

// MARK: - Work Log Data Model
struct WorkLog {
    let id: Int
    let timestamp: String
    let project: String
    let description: String

    var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: timestamp) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .short
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return timestamp
    }
}

// MARK: - Logs Viewer Window with Modern Table View
class LogsWindow: NSObject, NSWindowDelegate {
    var window: NSWindow!
    var tableView: NSTableView!
    var database: OpaquePointer?
    var logs: [WorkLog] = []

    init(database: OpaquePointer?) {
        self.database = database
        super.init()
    }

    func showWindow() {
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: 600),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        window.title = "Work Logs"
        window.delegate = self
        window.center()
        window.isReleasedWhenClosed = false
        window.minSize = NSSize(width: 600, height: 400)

        setupUI()
        loadLogs()
        window.makeKeyAndOrderFront(nil)
    }

    func setupUI() {
        let contentView = NSView(frame: window.contentRect(forFrameRect: window.frame))
        contentView.wantsLayer = true
        window.contentView = contentView

        // Create scroll view
        let scrollView = NSScrollView(frame: contentView.bounds)
        scrollView.autoresizingMask = [.width, .height]
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = false
        scrollView.borderType = .noBorder

        // Create table view
        tableView = NSTableView()
        tableView.style = .inset
        tableView.headerView = NSTableHeaderView()
        tableView.cornerView = nil
        tableView.allowsColumnResizing = true
        tableView.allowsColumnReordering = false
        tableView.intercellSpacing = NSSize(width: 0, height: 0)
        tableView.usesAlternatingRowBackgroundColors = true
        tableView.gridStyleMask = [.solidHorizontalGridLineMask]

        // Create columns with proper identifiers
        createTableColumns()

        // Set up data source and delegate
        tableView.dataSource = self
        tableView.delegate = self

        scrollView.documentView = tableView
        contentView.addSubview(scrollView)

        // Add refresh button
        let refreshButton = NSButton(frame: NSRect(x: 20, y: contentView.bounds.height - 40, width: 80, height: 24))
        refreshButton.title = "Refresh"
        refreshButton.bezelStyle = .rounded
        refreshButton.target = self
        refreshButton.action = #selector(refreshLogs)
        refreshButton.autoresizingMask = [.maxXMargin, .minYMargin]
        contentView.addSubview(refreshButton)

        print("Modern table view setup complete")
    }

    func createTableColumns() {
        // Time column
        let timeColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("time"))
        timeColumn.title = "Time"
        timeColumn.width = 140
        timeColumn.minWidth = 120
        timeColumn.maxWidth = 180
        tableView.addTableColumn(timeColumn)

        // Project column
        let projectColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("project"))
        projectColumn.title = "Project"
        projectColumn.width = 150
        projectColumn.minWidth = 100
        projectColumn.maxWidth = 250
        tableView.addTableColumn(projectColumn)

        // Description column
        let descriptionColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("description"))
        descriptionColumn.title = "Description"
        descriptionColumn.width = 400
        descriptionColumn.minWidth = 200
        descriptionColumn.resizingMask = .autoresizingMask
        tableView.addTableColumn(descriptionColumn)
    }

    @objc func refreshLogs() {
        loadLogs()
    }

    // FIXED: Safer string extraction from SQLite with proper NULL checking
    func stringFromSQLite(_ statement: OpaquePointer?, _ index: Int32) -> String {
        // Use the method from AppDelegate for consistency
        if let appDelegate = NSApp.delegate as? AppDelegate {
            return appDelegate.stringFromSQLite(statement, index)
        }

        // Fallback implementation
        guard let statement = statement else {
            print("Statement is nil for column \(index)")
            return ""
        }

        // Check if the column is NULL
        if sqlite3_column_type(statement, index) == SQLITE_NULL {
            print("Column \(index) is NULL")
            return ""
        }

        // Get the text - sqlite3_column_text returns a pointer to UTF-8 text
        guard let cString = sqlite3_column_text(statement, index) else {
            print("Column \(index) returned NULL pointer")
            return ""
        }

        let result = String(cString: cString)
        print("Column \(index) value: '\(result)'")
        return result
    }

    func loadLogs() {
        logs.removeAll()

        guard let database = database else {
            print("Database is nil")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            return
        }

        let querySQL = "SELECT id, timestamp, project, description FROM work_logs ORDER BY timestamp DESC"
        var statement: OpaquePointer?

        print("Executing query: \(querySQL)")

        if sqlite3_prepare_v2(database, querySQL, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int(statement, 0)
                print("Processing row with ID: \(id)")

                // Use the shared string extraction method
                let timestamp = stringFromSQLite(statement, 1)
                let project = stringFromSQLite(statement, 2)
                let description = stringFromSQLite(statement, 3)

                let log = WorkLog(
                    id: Int(id),
                    timestamp: timestamp,
                    project: project,
                    description: description
                )

                logs.append(log)
                print("Loaded log: ID=\(id), timestamp='\(timestamp)', project='\(project)', description='\(description)'")
            }
            print("Loaded \(logs.count) logs from database")
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(database))
            print("Could not prepare statement: \(errorMessage)")
        }

        sqlite3_finalize(statement)

        // Reload table on main thread
        DispatchQueue.main.async {
            print("Reloading table view with \(self.logs.count) items")
            self.tableView.reloadData()
        }
    }

    // Clean up reference when window closes
    func windowWillClose(_ notification: Notification) {
        if let appDelegate = NSApp.delegate as? AppDelegate {
            if appDelegate.currentLogsWindow === self {
                appDelegate.currentLogsWindow = nil
            }
        }
    }
}

// MARK: - Table View Data Source
extension LogsWindow: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        print("numberOfRows called, returning: \(logs.count)")
        return logs.count
    }
}

// MARK: - Table View Delegate
extension LogsWindow: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard row < logs.count,
              let identifier = tableColumn?.identifier else {
            print("Invalid row \(row) or identifier")
            return nil
        }

        let log = logs[row]
        print("Creating cell for row \(row), column \(identifier.rawValue)")
        print("Log data: timestamp='\(log.timestamp)', project='\(log.project)', description='\(log.description)'")

        // Create or reuse cell view
        var cellView = tableView.makeView(withIdentifier: identifier, owner: self) as? NSTableCellView

        if cellView == nil {
            cellView = NSTableCellView()
            cellView?.identifier = identifier

            // Create text field
            let textField = NSTextField()
            textField.isEditable = false
            textField.isBordered = false
            textField.backgroundColor = .clear
            textField.translatesAutoresizingMaskIntoConstraints = false

            cellView?.addSubview(textField)
            cellView?.textField = textField

            // Add constraints
            NSLayoutConstraint.activate([
                textField.leadingAnchor.constraint(equalTo: cellView!.leadingAnchor, constant: 4),
                textField.trailingAnchor.constraint(equalTo: cellView!.trailingAnchor, constant: -4),
                textField.centerYAnchor.constraint(equalTo: cellView!.centerYAnchor)
            ])
        }

        // Set the cell content based on column
        var cellValue = ""
        switch identifier.rawValue {
        case "time":
            cellValue = log.formattedDate
            cellView?.textField?.font = NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular)
        case "project":
            cellValue = log.project
            cellView?.textField?.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        case "description":
            cellValue = log.description
            cellView?.textField?.font = NSFont.systemFont(ofSize: 13)
            cellView?.textField?.lineBreakMode = .byTruncatingTail
        default:
            cellValue = ""
        }

        cellView?.textField?.stringValue = cellValue
        print("Set cell value for \(identifier.rawValue): '\(cellValue)'")
        return cellView
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 22
    }
}
