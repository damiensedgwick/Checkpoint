import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel(
        dataManager: DataManager.shared,
        loginItemService: LoginItemService.shared
    )
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 4) {
                Image(systemName: "gear.badge")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.blue, .primary)
                    .font(.largeTitle)

                Text("Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .padding()

            // Settings Content
            VStack(spacing: 16) {
                // About
                SettingsSection(title: "About") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Version")
                                .font(.headline)
                            Spacer()
                            Text("1.1.0")
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Text("Build")
                                .font(.headline)
                            Spacer()
                            Text("1")
                                .foregroundColor(.secondary)
                        }

                        Text("Checkpoint helps you track your work sessions with ease, stay in the zone, and maintain consistent productivity throughout your day.")
                            .lineLimit(3...5)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // App Behavior
                SettingsSection(title: "App Behavior") {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Auto-start on Login")
                                    .font(.headline)
                                Text("Automatically start Checkpoint when you log in")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Toggle("", isOn: Binding(
                                get: { viewModel.isAutoStartEnabled },
                                set: { _ in viewModel.toggleAutoStart() }
                            ))
                        }
                    }
                }

                // Data Management
                SettingsSection(title: "Data Management") {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Your logs")
                                    .font(.headline)
                                Text("\(viewModel.logCount) logs stored")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Button("Export") {
                                viewModel.exportLogs()
                            }
                            .buttonStyle(.bordered)
                            .disabled(!viewModel.hasLogs)
                        }

                        Divider()

                        Button("Reset All Data") {
                            viewModel.resetAllData()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .disabled(!viewModel.hasLogs)
                    }
                }
            }
            .padding()


            Spacer()

            // Close Button
            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .frame(width: 400, height: 650)
        .background(Color(.windowBackgroundColor))
        .alert("Reset All Data", isPresented: $viewModel.showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                viewModel.confirmReset()
            }
        } message: {
            Text("This will permanently delete all your logs. This action cannot be undone.")
        }
        .fileExporter(
            isPresented: $viewModel.showingExportSheet,
            document: LogExportDocument(logs: viewModel.logEntries),
            contentType: .json,
            defaultFilename: "checkpoint-logs-\(Date().formatted(.dateTime.year().month().day()))"
        ) { result in
            switch result {
            case .success(let url):
                viewModel.exportAlertMessage = "Logs exported successfully to:\n\(url.lastPathComponent)"
                viewModel.showingExportAlert = true
            case .failure(let error):
                viewModel.exportAlertMessage = "Failed to export logs: \(error.localizedDescription)"
                viewModel.showingExportAlert = true
            }
        }
        .alert("Export Result", isPresented: $viewModel.showingExportAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.exportAlertMessage)
        }
        .alert("Auto-start Error", isPresented: Binding(
            get: { viewModel.hasError },
            set: { if !$0 { viewModel.clearError() } }
        )) {
            Button("OK") { viewModel.clearError() }
        } message: {
            if let error = viewModel.lastError {
                Text(error)
            }
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            content
                .padding()
                .background(Color(.controlBackgroundColor))
                .cornerRadius(8)
        }
    }
}

struct LogExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    let logs: [LogEntry]

    init(logs: [LogEntry]) {
        self.logs = logs
    }

    init(configuration: ReadConfiguration) throws {
        logs = []
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(logs)
        return FileWrapper(regularFileWithContents: data)
    }
}

#Preview {
    SettingsView()
}
