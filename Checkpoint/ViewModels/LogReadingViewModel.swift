import Foundation
import SwiftUI
import Combine

@MainActor
class LogReadingViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var searchText = ""
    @Published var showingDeleteAlert = false
    @Published var entryToDelete: LogEntry?
    @Published var logEntries: [LogEntry] = []
    
    // MARK: - Services
    private let dataManager: DataManager
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(dataManager: DataManager) {
        self.dataManager = dataManager
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        dataManager.$logEntries
            .assign(to: \.logEntries, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func deleteEntry(_ entry: LogEntry) {
        entryToDelete = entry
        showingDeleteAlert = true
    }
    
    func confirmDelete() {
        if let entry = entryToDelete {
            dataManager.deleteLogEntry(entry)
            entryToDelete = nil
        }
    }
    
    func clearSearch() {
        searchText = ""
    }
    
    // MARK: - Computed Properties
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
    
    var hasEntries: Bool {
        return !logEntries.isEmpty
    }
    
    var hasFilteredResults: Bool {
        return !filteredEntries.isEmpty
    }
    
    var isSearching: Bool {
        return !searchText.isEmpty
    }
}
