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
    @Published var selectedIntervalId: String

    var intervals: [Interval] {
        dataManager.availableIntervals
    }

    private let dataManager: DataManager

    init(dataManager: DataManager) {
        self.dataManager = dataManager
        self.selectedIntervalId = dataManager.loadSelectedIntervalId()
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
