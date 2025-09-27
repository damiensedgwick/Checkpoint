//
//  LogEntryStore.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 17/09/2025.
//

import Foundation
import Combine

@MainActor
class LogEntryStore: ObservableObject {
    static let shared = LogEntryStore()

    @Published private(set) var logEntries: [LogEntry] = []

    private let dataManager: DataManagingProtocol
    private var cancellables = Set<AnyCancellable>()

    private init() {
        self.dataManager = DataManagerService()
        setupSubscriptions()
        loadEntries()
    }

    private func setupSubscriptions() {
        dataManager.logEntriesPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.logEntries, on: self)
            .store(in: &cancellables)
    }

    private func loadEntries() {
        logEntries = dataManager.loadLogEntries()
    }

    func saveLogEntry(_ logEntry: LogEntry, timeSpent: Duration) async throws {
        try await dataManager.saveLogEntry(logEntry, timeSpent: timeSpent)
    }

    func updateLogEntry(_ logEntry: LogEntry) async throws {
        try await dataManager.updateLogEntry(logEntry)
    }

    func deleteLogEntry(_ logEntry: LogEntry) async throws {
        try await dataManager.deleteLogEntry(logEntry)
    }

    func deleteAllLogs() async throws {
        try await dataManager.deleteAllLogs()
    }
}
