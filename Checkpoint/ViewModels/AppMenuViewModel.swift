//
//  AppMenuViewModel.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 14/09/2025.
//

import Combine
import Foundation

@MainActor
class AppMenuViewModel: ObservableObject {
    @Published var selectedIntervalId: String

    var intervals: [Interval] {
        dataManager.availableIntervals
    }

    private let dataManager: DataManaging

    init(dataManager: DataManaging) {
        self.dataManager = dataManager
        self.selectedIntervalId = dataManager.loadSelectedIntervalId()
    }

    convenience init() {
        self.init(dataManager: DataManager())
    }

    func selectInterval(withID id: String) {
        guard dataManager.interval(withId: id) != nil else { return }

        selectedIntervalId = id
        dataManager.saveSelectedIntervalId(id)
    }

    func isIntervalSelected(_ interval: Interval) -> Bool {
        interval.id == selectedIntervalId
    }
}
