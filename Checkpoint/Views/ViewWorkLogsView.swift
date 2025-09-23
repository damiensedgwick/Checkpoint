//
//  AboutWindowView.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 16/09/2025.
//

import SwiftUI

struct ViewWorkLogsView: View {
    @State private var showTextField: Bool = false
    @FocusState private var isTextFieldFocused: Bool

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
                    .buttonStyle(.glass)
                }
                Spacer()
            } else {
                VStack {
                    HStack {
                        if viewModel.logEntries.count > 1 {
                            Text("\(viewModel.filteredEntries.count) entries")
                                .font(.subheadline)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .glassEffect()
                        } else {
                            Text("\(viewModel.logEntries.count) entry")
                                .font(.subheadline)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .glassEffect()
                        }

                        Spacer()

                        HStack(spacing: 0) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showTextField.toggle()
                                }
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .font(.subheadline)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .buttonStyle(.borderless)

                            if showTextField {
                                TextField("Search", text: $viewModel.searchText)
                                    .textFieldStyle(.plain)
                                    .font(.subheadline)
                                    .frame(maxWidth: 300)
                                    .focused($isTextFieldFocused)
                                    .animation(.easeInOut(duration: 0.3), value: showTextField)
                            }
                        }
                        .glassEffect()
                        .animation(.easeInOut(duration: 0.3), value: showTextField)
                    }
                    .padding(.horizontal, 15)
                    .padding(.top, 5)
                    .onChange(of: showTextField) {
                        if showTextField {
                            isTextFieldFocused = true
                        }
                    }
                    .onChange(of: isTextFieldFocused) {
                        if !isTextFieldFocused && showTextField {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showTextField = false
                            }
                        }
                    }

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

                        TableColumn("Duration") { entry in
                            Text(entry.formattedTimeSpent)
                        }
                        .width(min: 45, ideal: 45)

                        TableColumn("Actions") { entry in
                            HStack(spacing: 10) {
                                Button(action: {
                                    viewModel.editEntry(entry)
                                }) {
                                    Image(systemName: "pencil")
                                        .font(.subheadline)
                                        .padding(.horizontal, 3)
                                        .padding(.vertical, 3)
                                }
                                .buttonBorderShape(.circle)
                                .buttonStyle(.glass)

                                Button(action: {
                                    viewModel.deleteEntry(entry)
                                }) {
                                    Image(systemName: "trash")
                                        .font(.subheadline)
                                        .padding(.horizontal, 3)
                                        .padding(.vertical, 3)
                                }
                                .buttonBorderShape(.circle)
                                .buttonStyle(.glass)
                            }
                        }
                        .width(min: 20, ideal: 20)
                    }
                }
            }
        }
        .alert("Delete log entry", isPresented: $viewModel.showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }.buttonStyle(.glass)
            Button("Delete", role: .destructive) {
                viewModel.confirmDelete()
            }
            .buttonStyle(.glass)
        } message: {
            Text("This action is permanent and cannot be undone")
        }
        .alert("Delete all logs", isPresented: $viewModel.showingDeleteAllAlert) {
            Button("Cancel", role: .cancel) { }
                .buttonStyle(.glass)
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.confirmDeleteAllEntries()
                }
            }
            .buttonStyle(.glass)
        } message: {
            Text("This action is permanent and cannot be undone")
        }
        .alert("Error", isPresented: $viewModel.showingErrorAlert) {
            Button("OK", role: .cancel) { }.buttonStyle(.glass)
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
