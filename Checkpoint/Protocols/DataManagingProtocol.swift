//
//  DataManaging.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 15/09/2025.
//

import Foundation

protocol DataManagingProtocol {
    var availableIntervals: [Interval] { get }
    var defaultIntervalId: String { get }

    func loadSelectedIntervalId() -> String
    func saveSelectedIntervalId(_ intervalId: String)
    func interval(withId id: String) -> Interval?
}
