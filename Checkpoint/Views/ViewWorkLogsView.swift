//
//  AboutWindowView.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 16/09/2025.
//

import SwiftUI

struct ViewWorkLogsView: View {
    @StateObject private var viewModel = ViewWorkLogsViewModel()
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack {
            if viewModel.logEntries.isEmpty {
                Spacer()
                VStack {
                    Text("No log entries found")
                        .foregroundStyle(.secondary)
                    
                    Button("Add a new log entry") {
                        openWindow(id: "logwork")
                    }
                }
                Spacer()
            } else {
                VStack {
                    HStack {
                        VStack {
                            HStack {
                                Image(systemName: "magnifyingglass")

                                TextField("Search logs", text: $viewModel.searchText)
                                    .textFieldStyle(.plain)
                            }
                        }

                        HStack(spacing: 20) {
                            if viewModel.logEntries.count > 1 {
                                Text("\(viewModel.logEntries.count) entries")
                            } else {
                                Text("\(viewModel.logEntries.count) entry")
                            }

                            Button(action: {
                                viewModel.deleteAllEntries()
                            }) {
                                Text("Delete All")
                            }
                        }
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 14)
                    
                    Table(viewModel.filteredEntries) {
                        TableColumn("Date") { entry in
                            Text(entry.formattedDate)
                        }
                        .width(min: 80, ideal: 80)
                        
                        TableColumn("Time") { entry in
                            Text(entry.formattedTime)
                        }
                        .width(min: 45, ideal: 45)
                        
                        TableColumn("Project") { entry in
                            Text(entry.project)
                        }
                        .width(min: 120, ideal: 120)
                        
                        TableColumn("Description") { entry in
                            Text(entry.description)
                        }
                        .width(min: 300, ideal: 300)
                        
                        TableColumn("Time Spent") { entry in
                            Text(entry.formattedTimeSpent)
                        }
                        .width(min: 45, ideal: 45)
                        
                        TableColumn("Delete") { entry in
                            Button(action: {
                                viewModel.deleteEntry(entry)
                            }) {
                                Image(systemName: "trash")
                            }
                        }
                        .width(min: 20, ideal: 20)
                    }
                }
            }
        }
        .alert("Delete log entry", isPresented: $viewModel.showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.confirmDelete()
            }
        } message: {
            Text("This action is permanent and cannot be undone")
        }
        .alert("Delete all logs", isPresented: $viewModel.showingDeleteAllAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.confirmDeleteAllEntries()
                }
            }
        } message: {
            Text("This action is permanent and cannot be undone")
        }
        .alert("Error", isPresented: $viewModel.showingErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .disabled(viewModel.isDeleting)
    }
}

#Preview {
    ViewWorkLogsView()
        .frame(width: 900, height: 500)
}
