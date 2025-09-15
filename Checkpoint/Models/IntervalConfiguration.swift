//
//  IntervalConfiguration.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 14/09/2025.
//

import Foundation

enum IntervalConfiguration {
    static let defaultIntervalId = "30min"

    static var allIntervals: [Interval] {
        var intervals = [
            Interval(
                id: "15min",
                label: "15 Minutes",
                duration: .seconds(900)
            ),
            Interval(
                id: "30min",
                label: "30 Minutes",
                duration: .seconds(1800)
            ),
            Interval(
                id: "45min",
                label: "45 Minutes",
                duration: .seconds(2700)
            ),
            Interval(
                id: "60min",
                label: "60 Minutes",
                duration: .seconds(3600)
            ),
            Interval(
                id: "90min",
                label: "90 Minutes",
                duration: .seconds(5400)
            )
        ]

        #if DEBUG
        intervals.insert(
            Interval(
                id: "1min",
                label: "1 Minute",
                duration: .seconds(60)
            ),
            at: 0
        )
        #endif

        return intervals
    }

    static func interval(withId id: String) -> Interval? {
        allIntervals.first { $0.id == id }
    }

    static var defaultInterval: Interval {
        interval(withId: defaultIntervalId) ?? allIntervals[0]
    }
}