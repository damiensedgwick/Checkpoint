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
        VStack {
            VStack {
                VStack {
                    VStack {
                        Text("Project")
                        
                        TextField("Enter project name", text: $viewModel.project)
                    }
                    
                    VStack {
                        Text("Description")
                        
                        TextEditor(text: $viewModel.description)
                    }
                }
            }
            
            HStack(spacing: 16) {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                .buttonStyle(.borderless)

                Button("Save Log Entry") {
                    Task {
                        await viewModel.saveLogEntry()
                        if viewModel.saveSucceeded {
                            dismiss()
                        }
                    }
                }
                .disabled(!viewModel.isFormValid || viewModel.isLoading)
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.glass)
            }
        }
        .padding()
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
