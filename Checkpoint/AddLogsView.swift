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
    @Environment(\.openWindow) private var openWindow
    @StateObject private var dataManager = DataManager.shared
    
    @State private var project = ""
    @State private var description = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
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
                    
                    TextField("Enter project name", text: $project)
                        .textFieldStyle(.roundedBorder)
                }
                
                // Description
                VStack(alignment: .leading, spacing: 6) {
                    Text("Description")
                        .font(.headline)
                    
                    TextEditor(text: $description)
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
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Button("Save") {
                    saveLog()
                }
                .buttonStyle(.borderedProminent)
                .disabled(project.isEmpty || description.isEmpty)
            }
            .padding(.bottom, 20)
        }
        .frame(width: 350, height: 280)
        .background(Color(.windowBackgroundColor))
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func saveLog() {
        guard !project.isEmpty else {
            alertMessage = "Please enter a project name"
            showingAlert = true
            return
        }
        
        guard !description.isEmpty else {
            alertMessage = "Please enter a description"
            showingAlert = true
            return
        }
        
        let entry = LogEntry(
            project: project.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        dataManager.saveLogEntry(entry)
        dismiss()
        
        // Show success notification
        let content = UNMutableNotificationContent()
        content.title = "Log Saved"
        content.body = "Your work has been logged successfully"
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: "log-saved", content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error)")
            }
        }
    }
}



#Preview {
    LoggingView()
}
