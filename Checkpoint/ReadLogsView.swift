//
//  ReadLogsView.swift
//  checkpoint
//
//  Created by Damien Sedgwick on 05/07/2025.
//

import SwiftUI

struct LogEntry: Identifiable {
    let id = UUID()
    let date: Date
    let project: String
    let description: String
}

struct LogReadingView: View {
    // Sample data - replace with your actual data source
    @State private var logEntries: [LogEntry] = [
        LogEntry(date: Date(), project: "Project A", description: "Initial setup and configuration"),
        LogEntry(date: Date().addingTimeInterval(-3600), project: "Project B", description: "Bug fixes and testing"),
        LogEntry(date: Date().addingTimeInterval(-7200), project: "Project A", description: "Feature implementation"),
        LogEntry(date: Date().addingTimeInterval(-10800), project: "Project C", description: "Code review and documentation"),
        LogEntry(date: Date().addingTimeInterval(-14400), project: "Project B", description: "Performance optimization")
    ]

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("Checkpoint Logs")
                    .font(.title)
                    .fontWeight(.bold)

                Spacer()

                Text("Total Entries: \(logEntries.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 15)
            .padding(.top, 15)


            // Table
            Table(logEntries) {
                TableColumn("Date") { entry in
                    Text(dateFormatter.string(from: entry.date))
                        .font(.system(.body, design: .monospaced))
                }
                .width(min: 80, ideal: 80)

                TableColumn("Time") { entry in
                    Text(timeFormatter.string(from: entry.date))
                        .font(.system(.body, design: .monospaced))
                }
                .width(min: 40, ideal: 40)

                TableColumn("Project") { entry in
                    Text(entry.project)
                        .fontWeight(.medium)
                }
                .width(min: 100, ideal: 100)

                TableColumn("Description") { entry in
                    Text(entry.description)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }
                .width(min: 200)
            }
            .tableStyle(.inset(alternatesRowBackgrounds: true))
        }
        .frame(minWidth: 800, minHeight: 600)
        .background()
    }
}

#Preview {
    LogReadingView()
}
