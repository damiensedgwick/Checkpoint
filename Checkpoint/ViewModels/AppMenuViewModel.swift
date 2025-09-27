//
//  AppMenuViewModel.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 14/09/2025.
//

import Combine
import Foundation
import ServiceManagement

@MainActor
class AppMenuViewModel: ObservableObject {
    @Published var selectedIntervalId: String
    @Published var showingExporter = false
    @Published var exportDocument: CSVDocument?
    @Published var launchAtLogin = false

    var intervals: [Interval] {
        dataManager.availableIntervals
    }

    private let dataManager: DataManagingProtocol

    init(dataManager: DataManagingProtocol) {
        self.dataManager = dataManager
        self.selectedIntervalId = dataManager.loadSelectedIntervalId()
        self.launchAtLogin = SMAppService.mainApp.status == .enabled
    }

    convenience init() {
        self.init(dataManager: DataManagerService())
    }

    func selectInterval(withID id: String) {
        guard dataManager.interval(withId: id) != nil else { return }

        selectedIntervalId = id
        dataManager.saveSelectedIntervalId(id)
    }

    func isIntervalSelected(_ interval: Interval) -> Bool {
        interval.id == selectedIntervalId
    }
    
    func deleteAllLogs() async {
        try? await dataManager.deleteAllLogs()
    }
    
    func downloadAllData() {
        exportDocument = dataManager.downloadAllData()
        showingExporter = true
    }

    func toggleLaunchAtLogin() {
        if launchAtLogin {
            disableLaunchAtLogin()
        } else {
            enableLaunchAtLogin()
        }
    }

    private func enableLaunchAtLogin() {
        do {
            try SMAppService.mainApp.register()
            launchAtLogin = true
        } catch {
            print("Failed to enable launch at login: \(error.localizedDescription)")
        }
    }

    private func disableLaunchAtLogin() {
        do {
            try SMAppService.mainApp.unregister()
            launchAtLogin = false
        } catch {
            print("Failed to disable launch at login: \(error.localizedDescription)")
        }
    }
}
