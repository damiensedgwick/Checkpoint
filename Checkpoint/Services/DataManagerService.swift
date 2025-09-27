//
//  DataManagerService.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 14/09/2025.
//

import Foundation
import Combine

@MainActor
class DataManagerService: DataManagingProtocol, ObservableObject {
    @Published private(set) var logEntries: [LogEntry] = []

    private let userDefaults = UserDefaults.standard
    private let intervalKey = "checkpoint_interval"
    private let logEntriesKey = "checkpoint_log_entries"

    private let logEntriesSubject = CurrentValueSubject<[LogEntry], Never>([])

    var availableIntervals: [Interval] {
        IntervalConfiguration.allIntervals
    }

    var defaultIntervalId: String {
        IntervalConfiguration.defaultIntervalId
    }

    var logEntriesPublisher: AnyPublisher<[LogEntry], Never> {
        logEntriesSubject.eraseToAnyPublisher()
    }

    init() {
        loadLogEntries()
    }

    func loadSelectedIntervalId() -> String {
        if let savedIntervalId = userDefaults.string(forKey: intervalKey),
           availableIntervals.contains(where: { $0.id == savedIntervalId }) {
            #if DEBUG
            print("Loaded interval ID: \(savedIntervalId)")
            #endif
            return savedIntervalId
        }

        #if DEBUG
        print("No saved interval found, using default: \(defaultIntervalId)")
        #endif
        return defaultIntervalId
    }

    func saveSelectedIntervalId(_ intervalId: String) {
        userDefaults.set(intervalId, forKey: intervalKey)
        #if DEBUG
        print("Saved interval ID: \(intervalId)")
        #endif
    }

    func interval(withId id: String) -> Interval? {
        availableIntervals.first { $0.id == id }
    }

    @discardableResult
    func loadLogEntries() -> [LogEntry] {
        do {
            if let data = userDefaults.data(forKey: logEntriesKey) {
                let decoder = JSONDecoder()
                let entries = try decoder.decode([LogEntry].self, from: data)
                logEntries = entries
                logEntriesSubject.send(entries)

                #if DEBUG
                print("Loaded \(entries.count) log entries")
                #endif
            }
        } catch {
            #if DEBUG
            print("Failed to load log entries: \(error)")
            #endif
            logEntries = []
            logEntriesSubject.send([])
        }

        return logEntries
    }

    func saveLogEntry(_ logEntry: LogEntry, timeSpent: Duration) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let entry = LogEntry(
                    project: logEntry.project,
                    description: logEntry.description,
                    timeSpent: timeSpent
                )

                logEntries.insert(entry, at: 0)
                try saveLogEntriesToStorage()
                logEntriesSubject.send(logEntries)

                #if DEBUG
                print("Successfully saved log entry: \(entry.project)")
                #endif

                continuation.resume()
            } catch {
                #if DEBUG
                print("Failed to save log entry: \(error)")
                #endif
                continuation.resume(throwing: DataManagerError.saveError(error.localizedDescription))
            }
        }
    }

    func deleteLogEntry(_ logEntry: LogEntry) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                logEntries.removeAll { $0.id == logEntry.id }
                try saveLogEntriesToStorage()
                logEntriesSubject.send(logEntries)

                #if DEBUG
                print("Successfully deleted log entry: \(logEntry.project)")
                #endif

                continuation.resume()
            } catch {
                #if DEBUG
                print("Failed to delete log entry: \(error)")
                #endif
                continuation.resume(throwing: DataManagerError.deleteError(error.localizedDescription))
            }
        }
    }

    func deleteAllLogs() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                logEntries.removeAll()
                try saveLogEntriesToStorage()
                logEntriesSubject.send(logEntries)

                #if DEBUG
                print("Successfully deleted all log entries")
                #endif

                continuation.resume()
            } catch {
                #if DEBUG
                print("Failed to delete all log entries: \(error)")
                #endif
                continuation.resume(throwing: DataManagerError.deleteError(error.localizedDescription))
            }
        }
    }
    
    func downloadAllData() {}

    private func saveLogEntriesToStorage() throws {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(logEntries)
            userDefaults.set(data, forKey: logEntriesKey)

            if !userDefaults.synchronize() {
                throw DataManagerError.saveError("Failed to synchronize UserDefaults")
            }
        } catch let error as EncodingError {
            throw DataManagerError.saveError("Encoding failed: \(error.localizedDescription)")
        } catch {
            throw DataManagerError.saveError(error.localizedDescription)
        }
    }
}
