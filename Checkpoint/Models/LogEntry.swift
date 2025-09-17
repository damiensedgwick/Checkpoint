//
//  LogEntry.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 17/09/2025.
//

import Foundation

struct LogEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let project: String
    let description: String
    let timeSpent: Duration?

    init(
        date: Date = Date(),
        project: String,
        description: String,
        timeSpent: Duration? = nil
    ) {
        self.id = UUID()
        self.date = date
        self.project = project
        self.description = description
        self.timeSpent = timeSpent
    }
}

extension LogEntry {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var formattedTimeSpent: String {
        guard let timeSpent else { return "-" }
        return timeSpent.formatted(.units(allowed: [.minutes], width: .abbreviated))
    }
}
