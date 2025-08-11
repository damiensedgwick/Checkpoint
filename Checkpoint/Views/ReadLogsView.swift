//
//  ReadLogsView.swift
//  checkpoint
//
//  Created by Damien Sedgwick on 05/07/2025.
//

import SwiftUI

struct LogReadingView: View {
    @StateObject private var viewModel = LogReadingViewModel(
        dataManager: DataManager.shared
    )
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with search and filters
            VStack(spacing: 16) {
                HStack {
                    Text("Work Logs")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text("\(viewModel.filteredEntries.count) entries")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(.controlBackgroundColor))
                        .cornerRadius(8)
                }
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search logs...", text: $viewModel.searchText)
                        .textFieldStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.controlBackgroundColor))
                .cornerRadius(8)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            .background(Color(.windowBackgroundColor))
            
            // Content
            if !viewModel.hasFilteredResults {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.hasEntries ? "No matching logs" : "No logs yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    if !viewModel.hasEntries {
                        Text("Start by logging your first work session")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Try adjusting your search or filter")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Table(viewModel.filteredEntries) {
                    TableColumn("Date") { entry in
                        Text(entry.formattedDate)
                            .font(.system(.body, design: .monospaced))
                    }
                    .width(min: 80, ideal: 80)
                    
                    TableColumn("Time") { entry in
                        Text(entry.formattedTime)
                            .font(.system(.body, design: .monospaced))
                    }
                    .width(min: 60, ideal: 60)
                    
                    TableColumn("Project") { entry in
                        Text(entry.project)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(6)
                    }
                    .width(min: 120, ideal: 120)
                    
                    TableColumn("Description") { entry in
                        Text(entry.description)
                            .lineLimit(2)
                            .truncationMode(.tail)
                    }
                    .width(min: 300)
                    
                    TableColumn("Actions") { entry in
                        Button(action: {
                            viewModel.deleteEntry(entry)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                    .width(min: 60, ideal: 60)
                }
                .tableStyle(.inset(alternatesRowBackgrounds: true))
            }
        }
        .frame(minWidth: 700, minHeight: 400)
        .background(Color(.windowBackgroundColor))
        .alert("Delete Log", isPresented: $viewModel.showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.confirmDelete()
            }
        } message: {
            Text("Are you sure you want to delete this log entry?")
        }
    }
}

#Preview {
    LogReadingView()
}
