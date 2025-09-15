//
//  DataManager.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 14/09/2025.
//

import Foundation

class DataManager: DataManaging {
    private let userDefaults = UserDefaults.standard
    private let intervalKey = "checkpoint_interval"

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
}
