//
//  AddLogsView.swift
//  checkpoint
//
//  Created by Damien Sedgwick on 05/07/2025.
//

import SwiftUI
import UserNotifications

struct LoggingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = LoggingViewModel(
        dataManager: DataManager.shared
    )
    @StateObject private var windowService = WindowService.shared
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Log Work")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 20)
            
            // Form
            VStack(spacing: 16) {
                // Project
                VStack(alignment: .leading, spacing: 6) {
                    Text("Project")
                        .font(.headline)
                    
                    TextField("Enter project name", text: $viewModel.project)
                        .textFieldStyle(.roundedBorder)
                }
                
                // Description
                VStack(alignment: .leading, spacing: 6) {
                    Text("Description")
                        .font(.headline)
                    
                    TextEditor(text: $viewModel.description)
                        .frame(height: 60)
                        .padding(8)
                        .background(Color(.textBackgroundColor))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.separatorColor), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 12) {
                Button("Cancel") {
                    viewModel.resetState()
                    windowService.notifyLoggingWindowClosed()
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Button("Save") {
                    if viewModel.saveLog() {
                        viewModel.clearForm()
                        windowService.notifyLoggingWindowClosed()
                        dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.isFormValid)
            }
            .padding(.bottom, 20)
        }
        .frame(width: 350, height: 280)
        .background(Color(.windowBackgroundColor))
        .alert("Error", isPresented: $viewModel.showingAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.alertMessage)
        }
        .onDisappear {
            viewModel.resetState()
        }
    }
}

#Preview {
    LoggingView()
}

