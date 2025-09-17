//
//  AboutWindowView.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 16/09/2025.
//

import SwiftUI

struct ViewWorkLogsView: View {
    @StateObject private var viewModel = ViewWorkLogsViewModel()

    var body: some View {
        VStack {
            if viewModel.logEntries.isEmpty {
                Spacer()
                Text("No log entries found")
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")

                        TextField("Search log entries...", text: $viewModel.searchText)
                            .textFieldStyle(.plain)
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
                            Button(action: {}) {
                                Image(systemName: "trash")
                            }
                        }
                        .width(min: 20, ideal: 20)
                    }
                }
            }
        }
    }
}

#Preview {
    ViewWorkLogsView()
        .frame(width: 900, height: 500)
}
