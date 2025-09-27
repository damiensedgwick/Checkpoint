//
//  CSVDocument.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 27/09/2025.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct CSVDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }

    let csvContent: String

    init(logEntries: [LogEntry]) {
        self.csvContent = CSVDocument.generateCSV(from: logEntries)
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.csvContent = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = csvContent.data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }

    private static func generateCSV(from logEntries: [LogEntry]) -> String {
        var csv = "Date,Time,Project,Description,Time Spent (minutes)\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short

        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short

        for entry in logEntries {
            let date = dateFormatter.string(from: entry.date)
            let time = timeFormatter.string(from: entry.date)
            let project = escapeCSVField(entry.project)
            let description = escapeCSVField(entry.description)

            let timeSpentMinutes: String
            if let timeSpent = entry.timeSpent {
                let minutes = Int(timeSpent.components.seconds / 60)
                timeSpentMinutes = String(minutes)
            } else {
                timeSpentMinutes = ""
            }

            csv += "\(date),\(time),\(project),\(description),\(timeSpentMinutes)\n"
        }

        return csv
    }

    private static func escapeCSVField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return field
    }
}