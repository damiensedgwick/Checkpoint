//
//  DataManager.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 14/09/2025.
//

import Foundation

class DataManagerService: DataManagingProtocol {
    var logEntries: [LogEntry] = []

    private let userDefaults = UserDefaults.standard
    private let intervalKey = "checkpoint_interval"
    private let logEntriesKey = "checkpoint_log_entries"

    var availableIntervals: [Interval] {
        IntervalConfiguration.allIntervals
    }

    var defaultIntervalId: String {
        IntervalConfiguration.defaultIntervalId
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

    func loadLogEntries() -> [LogEntry] {
        if let logEntries = userDefaults.object(forKey: logEntriesKey) as? [LogEntry] {
            #if DEBUG
            print("Loaded \(logEntries.count) log entries")
            #endif
            return logEntries
        }

        #if DEBUG
        print("No saved log entries found")
        #endif
        return []
    }
}
