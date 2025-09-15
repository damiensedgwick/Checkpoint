//
//  Interval.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 14/09/2025.
//

import Combine
import Foundation

@MainActor
class DataManager: ObservableObject {

    @Published var interval: Interval

    private let userDefaults = UserDefaults.standard
    private let intervalKey = "checkpoint_interval"

    init() {
        // TODO: ADD COMMENT
        self.interval = Interval(
            id: "30min",
            label: "30 minutes",
            duration: .seconds(1800),
            isSelected: true
        )

        // TODO: ADD COMMENT
        load()
    }

    private func load() {
        if let savedIntervalId = userDefaults.string(forKey: intervalKey) {
            if let loadedInterval = getIntervalById(savedIntervalId) {
                self.interval = loadedInterval
                #if DEBUG
                print("Loaded interval: \(interval.label)")
                #endif
                return
            }
        }
        #if DEBUG
        print("No saved interval found, using default: \(interval.label)")
        #endif
    }

    private func getIntervalById(_ id: String) -> Interval? {
        let intervals = [
            Interval(id: "15min", label: "15 minutes", duration: .seconds(900), isSelected: false),
            Interval(id: "30min", label: "30 minutes", duration: .seconds(1800), isSelected: false),
            Interval(id: "45min", label: "45 minutes", duration: .seconds(2700), isSelected: false),
            Interval(id: "60min", label: "60 minutes", duration: .seconds(3600), isSelected: false),
            Interval(id: "90min", label: "90 minutes", duration: .seconds(5400), isSelected: false)
        ]

        #if DEBUG
        let debugInterval = Interval(id: "1min", label: "1 minute", duration: .seconds(60), isSelected: false)
        return intervals.first(where: { $0.id == id }) ?? (id == "1min" ? debugInterval : nil)
        #endif
    }

    func setInterval(_ interval: Interval) {
        self.interval = interval
        userDefaults.set(interval.id, forKey: intervalKey)
        #if DEBUG
        print("Saved interval: \(interval.label)")
        #endif
    }
}
