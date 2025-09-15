//
//  AppMenuViewModel.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 14/09/2025.
//

import Combine
import Foundation
import SwiftUI

@MainActor
class AppMenuViewModel: ObservableObject {
    @Published var intervals: [Interval]

    private let dataManager: DataManager

    init(dataManager: DataManager) {
        self.dataManager = dataManager

        self.intervals = [
            Interval(
                id: "15min",
                label: "15 Minutes",
                duration: .seconds(900),
                isSelected: false
            ),
            Interval(
                id: "30min",
                label: "30 Minutes",
                duration: .seconds(1800),
                isSelected: false
            ),
            Interval(
                id: "45min",
                label: "45 Minutes",
                duration: .seconds(2700),
                isSelected: false
            ),
            Interval(
                id: "60min",
                label: "60 Minutes",
                duration: .seconds(3600),
                isSelected: false
            ),
            Interval(
                id: "90min",
                label: "90 Minutes",
                duration: .seconds(5400),
                isSelected: false
            ),
        ]

        #if DEBUG
        intervals.insert(
            Interval(
                id: "1min",
                label: "1 Minute",
                duration: .seconds(60),
                isSelected: false
            ),
            at: 0
        )
        #endif

        updateSelectedInterval()
    }

    func selectInterval(withID id: String) {
        guard let selectedInterval = intervals.first(where: { $0.id == id }) else { return }

        for index in intervals.indices {
            intervals[index].isSelected = (intervals[index].id == id)
        }

        dataManager.setInterval(selectedInterval)
    }

    private func updateSelectedInterval() {
        let currentIntervalId = dataManager.interval.id
        for index in intervals.indices {
            intervals[index].isSelected = (intervals[index].id == currentIntervalId)
        }
    }
}
