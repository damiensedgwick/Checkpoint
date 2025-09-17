//
//  LogWorkView.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 16/09/2025.
//

import SwiftUI

struct LogWorkView: View {
    @StateObject private var viewModel = LogWorkViewModel()
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) private var dismiss
    
    enum Field: Hashable {
        case project, description
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 20) {
                // Form fields
                VStack(alignment: .leading, spacing: 16) {
                    // Project field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Project")
                            .font(.headline)
                        
                        TextField("Enter project name", text: $viewModel.project)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusedField, equals: .project)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Description")
                            .font(.headline)
                        
                        TextEditor(text: $viewModel.description)
                            .font(.system(.body))
                            .focused($focusedField, equals: .description)
                            .frame(minHeight: 80)
                            .background(Color(NSColor.textBackgroundColor))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                            )
                    }
                }
                
                Spacer()
                
                // Loading state
                if viewModel.isLoading {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Saving log entry...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            }
            .padding(24)
            
            HStack {
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Save Log Entry") {
                    Task {
                        await viewModel.saveLogEntry()
                        if viewModel.saveSucceeded {
                            dismiss()
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.isFormValid || viewModel.isLoading)
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .background(Color(NSColor.windowBackgroundColor))
        .onSubmit {
            switch focusedField {
            case .project:
                focusedField = .description
            case .description:
                Task {
                    await viewModel.saveLogEntry()
                    if viewModel.saveSucceeded {
                        dismiss()
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
    LogWorkView()
        .frame(width: 300, height: 300)
}
