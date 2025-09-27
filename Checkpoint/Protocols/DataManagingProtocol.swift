//
//  DataManagingProtocol.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 15/09/2025.
//

import Foundation
import Combine

enum DataManagerError: LocalizedError {
    case saveError(String)
    case loadError(String)
    case deleteError(String)
    case invalidData

    var errorDescription: String? {
        switch self {
        case .saveError(let message):
            return "Save failed: \(message)"
        case .loadError(let message):
            return "Load failed: \(message)"
        case .deleteError(let message):
            return "Delete failed: \(message)"
        case .invalidData:
            return "Invalid data format"
        }
    }
}

protocol DataManagingProtocol {
    var availableIntervals: [Interval] { get }
    var defaultIntervalId: String { get }
    var logEntries: [LogEntry] { get }
    var logEntriesPublisher: AnyPublisher<[LogEntry], Never> { get }

    func loadSelectedIntervalId() -> String
    func saveSelectedIntervalId(_ intervalId: String)
    func interval(withId id: String) -> Interval?

    func loadLogEntries() -> [LogEntry]
    func saveLogEntry(_ logEntry: LogEntry, timeSpent: Duration) async throws
    func deleteLogEntry(_ logEntry: LogEntry) async throws
    func deleteAllLogs() async throws
    
    func downloadAllData() -> CSVDocument
}
