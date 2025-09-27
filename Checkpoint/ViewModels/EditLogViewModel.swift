//
//  EditLogViewModel.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 27/09/2025.
//

import Combine
import Foundation

@MainActor
class EditLogViewModel: ObservableObject {
    @Published var project = ""
    @Published var description = ""
    @Published var date = Date()
    @Published var timeSpent = Duration.seconds(0)

    @Published var projectError: String?
    @Published var descriptionError: String?

    @Published var isLoading = false
    @Published var saveSucceeded = false
    @Published var showingSuccessAlert = false
    @Published var showingErrorAlert = false
    @Published var errorMessage = ""

    private let logEntryStore: LogEntryStore
    private let dataManager: DataManagingProtocol
    private var cancellables = Set<AnyCancellable>()
    private let originalEntry: LogEntry

    var isFormValid: Bool {
        projectError == nil &&
        descriptionError == nil &&
        !project.isEmpty &&
        !description.isEmpty
    }

    var hasChanges: Bool {
        let trimmedProject = project.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedProject != originalEntry.project ||
               trimmedDescription != originalEntry.description ||
               date != originalEntry.date ||
               timeSpent != originalEntry.timeSpent
    }

    var availableIntervals: [Interval] {
        dataManager.availableIntervals
    }

    var formattedTimeSpent: String {
        let totalSeconds = timeSpent.components.seconds
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    init(logEntry: LogEntry, logEntryStore: LogEntryStore? = nil, dataManager: DataManagingProtocol? = nil) {
        self.originalEntry = logEntry
        self.logEntryStore = logEntryStore ?? LogEntryStore.shared
        self.dataManager = dataManager ?? DataManagerService()

        // Pre-populate the form with existing data
        self.project = logEntry.project
        self.description = logEntry.description
        self.date = logEntry.date
        self.timeSpent = logEntry.timeSpent ?? Duration.seconds(0)

        setupValidation()
    }

    private func setupValidation() {
        $project
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .map { project in
                let trimmed = project.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmed.isEmpty ? "Project name is required" : nil
            }
            .assign(to: \.projectError, on: self)
            .store(in: &cancellables)

        $description
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .map { description in
                let trimmed = description.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmed.isEmpty ? "Description is required" : nil
            }
            .assign(to: \.descriptionError, on: self)
            .store(in: &cancellables)
    }

    func saveLogEntry() async {
        guard isFormValid && hasChanges else { return }

        isLoading = true
        saveSucceeded = false

        do {
            let updatedEntry = LogEntry(
                id: originalEntry.id,
                date: date,
                project: project.trimmingCharacters(in: .whitespacesAndNewlines),
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                timeSpent: timeSpent
            )

            try await logEntryStore.updateLogEntry(updatedEntry)

            saveSucceeded = true
            showingSuccessAlert = true

        } catch {
            errorMessage = error.localizedDescription
            showingErrorAlert = true
        }

        isLoading = false
    }

    func setTimeSpent(to duration: Duration) {
        timeSpent = duration
    }
}