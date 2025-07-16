//
//  ReadLogsView.swift
//  checkpoint
//
//  Created by Damien Sedgwick on 05/07/2025.
//

import SwiftUI

struct LogReadingView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var searchText = ""
    @State private var showingDeleteAlert = false
    @State private var entryToDelete: LogEntry?
    
    private var filteredEntries: [LogEntry] {
        if searchText.isEmpty {
            return dataManager.logEntries
        } else {
            return dataManager.logEntries.filter { entry in
                entry.project.localizedCaseInsensitiveContains(searchText) ||
                entry.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with search and filters
                VStack(spacing: 16) {
                    HStack {
                        Text("Work Logs")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text("\(filteredEntries.count) entries")
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
                        
                        TextField("Search logs...", text: $searchText)
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
                if filteredEntries.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text(dataManager.logEntries.isEmpty ? "No logs yet" : "No matching logs")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        if dataManager.logEntries.isEmpty {
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
                    Table(filteredEntries) {
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
                                entryToDelete = entry
                                showingDeleteAlert = true
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
        }
        .alert("Delete Log", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let entry = entryToDelete {
                    dataManager.deleteLogEntry(entry)
                    entryToDelete = nil
                }
            }
        } message: {
            Text("Are you sure you want to delete this log entry?")
        }
    }
}

#Preview {
    LogReadingView()
}
