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
    @Published var showingDeleteAlert = false
    @Published var showingDeleteAllAlert = false
    @Published var entryToDelete: LogEntry?
    @Published var isDeleting = false
    @Published var errorMessage = ""
    @Published var showingErrorAlert = false

    private let logEntryStore: LogEntryStore
    private var cancellables = Set<AnyCancellable>()

    init(logEntryStore: LogEntryStore? = nil) {
        self.logEntryStore = logEntryStore ?? LogEntryStore.shared
        setupSubscriptions()
    }

    private func setupSubscriptions() {
        logEntryStore.$logEntries
            .receive(on: DispatchQueue.main)
            .assign(to: \.logEntries, on: self)
            .store(in: &cancellables)
    }

    func editEntry(_ entry: LogEntry) {
        // TODO:    
    }

    func deleteEntry(_ entry: LogEntry) {
        entryToDelete = entry
        showingDeleteAlert = true
    }

    func confirmDelete() {
        guard let entry = entryToDelete else { return }

        isDeleting = true
        entryToDelete = nil

        Task {
            do {
                try await logEntryStore.deleteLogEntry(entry)
                #if DEBUG
                print("Successfully deleted entry: \(entry.project)")
                #endif
            } catch {
                errorMessage = error.localizedDescription
                showingErrorAlert = true
                #if DEBUG
                print("Failed to delete entry: \(error)")
                #endif
            }
            isDeleting = false
        }
    }

    func deleteAllEntries() {
        showingDeleteAllAlert = true
    }

    func confirmDeleteAllEntries() async {
        do {
            try await logEntryStore.deleteAllLogs()
            #if DEBUG
            print("Successfully deleted all entries")
            #endif
        } catch {
            errorMessage = error.localizedDescription
            showingErrorAlert = true
            #if DEBUG
            print("Failed to delete all entries: \(error)")
            #endif
        }
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
