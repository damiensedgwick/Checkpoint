//
//  EditLogView.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 27/09/2025.
//

import SwiftUI

struct EditLogView: View {
    @StateObject private var viewModel: EditLogViewModel
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) private var dismiss
    
    enum Field: Hashable {
        case project, description
    }
    
    init(logEntry: LogEntry) {
        self._viewModel = StateObject(wrappedValue: EditLogViewModel(logEntry: logEntry))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Project")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    
                    TextField("Enter project name", text: $viewModel.project)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
                        )
                        .focused($focusedField, equals: .project)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    
                    TextEditor(text: $viewModel.description)
                        .font(.body)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .frame(minHeight: 80)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
                        )
                        .focused($focusedField, equals: .description)
                }
            }
            
            HStack(spacing: 16) {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                .buttonStyle(.borderless)
                
                Button("Save Changes") {
                    Task {
                        await viewModel.saveLogEntry()
                        if viewModel.saveSucceeded {
                            dismiss()
                        }
                    }
                }
                .disabled(!viewModel.isFormValid || !viewModel.hasChanges || viewModel.isLoading)
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.glass)
            }
        }
        .padding()
        .frame(width: 300, height: 300)
        .onSubmit {
            switch focusedField {
            case .project:
                focusedField = .description
            case .description:
                if viewModel.isFormValid && viewModel.hasChanges {
                    Task {
                        await viewModel.saveLogEntry()
                        if viewModel.saveSucceeded {
                            dismiss()
                        }
                    }
                }
            case nil:
                break
            }
        }
        .alert("Error", isPresented: $viewModel.showingErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

#Preview {
    EditLogView(logEntry: LogEntry(
        project: "Sample Project",
        description: "Sample description for editing",
        timeSpent: Duration.seconds(1800)
    ))
    .frame(width: 300, height: 300)
}
