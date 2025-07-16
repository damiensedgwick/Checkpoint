import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @StateObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingResetAlert = false
    @State private var showingExportSheet = false
    
    private let intervals: [(String, TimeInterval)] = [
        ("15 minutes", 15 * 60),
        ("30 minutes", 30 * 60),
        ("45 minutes", 45 * 60),
        ("1 hour", 60 * 60),
        ("2 hours", 120 * 60),
        ("3 hours", 180 * 60),
        ("4 hours", 240 * 60)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "gear")
                        .font(.system(size: 32))
                        .foregroundColor(.accentColor)
                    
                    Text("Settings")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // Settings Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Timer Settings
                        SettingsSection(title: "Timer Settings") {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Default Interval")
                                    .font(.headline)
                                
                                Picker("Default Interval", selection: Binding(
                                    get: { dataManager.currentInterval },
                                    set: { dataManager.updateInterval($0) }
                                )) {
                                    ForEach(intervals, id: \.1) { name, interval in
                                        Text(name).tag(interval)
                                    }
                                }
                                .pickerStyle(.menu)
                                
                                Text("This interval will be used when starting a new timer")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Data Management
                        SettingsSection(title: "Data Management") {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Log Entries")
                                            .font(.headline)
                                        Text("\(dataManager.logEntries.count) entries stored")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button("Export") {
                                        showingExportSheet = true
                                    }
                                    .buttonStyle(.bordered)
                                }
                                
                                Divider()
                                
                                Button("Reset All Data") {
                                    showingResetAlert = true
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.red)
                                .disabled(dataManager.logEntries.isEmpty)
                            }
                        }
                        
                        // About
                        SettingsSection(title: "About") {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Version")
                                        .font(.headline)
                                    Spacer()
                                    Text("1.0.0")
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack {
                                    Text("Build")
                                        .font(.headline)
                                    Spacer()
                                    Text("1")
                                        .foregroundColor(.secondary)
                                }
                                
                                Text("Checkpoint helps you track your work sessions and maintain productivity.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 8)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                // Close Button
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 20)
            }
            .frame(width: 400, height: 500)
            .background(Color(.windowBackgroundColor))
        }
        .alert("Reset All Data", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                dataManager.clearAllLogs()
            }
        } message: {
            Text("This will permanently delete all your log entries. This action cannot be undone.")
        }
        .fileExporter(
            isPresented: $showingExportSheet,
            document: LogExportDocument(logs: dataManager.logEntries),
            contentType: .json,
            defaultFilename: "checkpoint-logs-\(Date().formatted(.dateTime.year().month().day()))"
        ) { _ in }
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
        let data = try JSONEncoder().encode(logs)
        return FileWrapper(regularFileWithContents: data)
    }
}

#Preview {
    SettingsView()
} 