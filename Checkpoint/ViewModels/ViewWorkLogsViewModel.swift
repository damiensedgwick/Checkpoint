//
//  ViewWorkLogsViewModel.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 17/09/2025.
//

import Combine
import Foundation

@MainActor
class ViewWorkLogsViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var logEntries: [LogEntry] = []

    private let dataManager: DataManagingProtocol

    init(dataManager: DataManagingProtocol) {
        self.dataManager = dataManager
        self.logEntries = dataManager.loadLogEntries()
    }

    convenience init() {
        self.init(dataManager: DataManagerService())
    }

    var filteredEntries: [LogEntry] {
        if searchText.isEmpty {
            return logEntries
        } else {
            return logEntries.filter { entry in
                entry.project.localizedCaseInsensitiveContains(searchText) ||
                entry.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
