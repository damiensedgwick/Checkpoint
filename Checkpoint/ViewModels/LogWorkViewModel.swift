//
//  LogWorkViewModel.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 17/09/2025.
//

import Combine
import Foundation

enum ValidationError: LocalizedError {
    case emptyProject
    case emptyDescription
    case invalidTime
    case saveFailed(String)

    var errorDescription: String? {
        switch self {
        case .emptyProject:
            return "Project name cannot be empty"
        case .emptyDescription:
            return "Description cannot be empty"
        case .invalidTime:
            return "Please enter a valid time (must be greater than 0)"
        case .saveFailed(let message):
            return "Save failed: \(message)"
        }
    }
}

@MainActor
class LogWorkViewModel: ObservableObject {
    @Published var project = ""
    @Published var description = ""

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

    var isFormValid: Bool {
        projectError == nil &&
        descriptionError == nil &&
        !project.isEmpty &&
        !description.isEmpty
    }

    var selectedInterval: Interval {
        let selectedId = dataManager.loadSelectedIntervalId()
        return dataManager.interval(withId: selectedId) ?? IntervalConfiguration.defaultInterval
    }

    var selectedIntervalLabel: String {
        selectedInterval.label
    }

    var timeSpent: Duration {
        selectedInterval.duration
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

    init(logEntryStore: LogEntryStore? = nil, dataManager: DataManagingProtocol? = nil) {
        self.logEntryStore = logEntryStore ?? LogEntryStore.shared
        self.dataManager = dataManager ?? DataManagerService()
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
        guard isFormValid else { return }

        isLoading = true
        saveSucceeded = false

        do {
            let logEntry = LogEntry(
                project: project.trimmingCharacters(in: .whitespacesAndNewlines),
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                timeSpent: timeSpent
            )

            try await logEntryStore.saveLogEntry(logEntry, timeSpent: timeSpent)

            saveSucceeded = true
            showingSuccessAlert = true
            clearForm()

        } catch {
            errorMessage = error.localizedDescription
            showingErrorAlert = true
        }

        isLoading = false
    }

    private func clearForm() {
        project = ""
        description = ""
        projectError = nil
        descriptionError = nil
    }
}
