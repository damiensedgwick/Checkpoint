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
    @State private var includeDuration = false
    @State private var duration: TimeInterval = 0
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private let commonProjects = ["Development", "Design", "Planning", "Testing", "Documentation", "Meeting", "Research"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "clock.badge.checkmark")
                        .font(.system(size: 48))
                        .foregroundColor(.accentColor)
                    
                    Text("Log Your Work")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Record what you've been working on")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Form
                VStack(spacing: 20) {
                    // Project Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Project")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            TextField("Enter project name", text: $project)
                                .textFieldStyle(.roundedBorder)
                            
                            Menu {
                                ForEach(commonProjects, id: \.self) { projectName in
                                    Button(projectName) {
                                        project = projectName
                                    }
                                }
                            } label: {
                                Image(systemName: "list.bullet")
                                    .foregroundColor(.accentColor)
                            }
                            .menuStyle(.borderlessButton)
                        }
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextEditor(text: $description)
                            .frame(minHeight: 80)
                            .padding(8)
                            .background(Color(.textBackgroundColor))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.separatorColor), lineWidth: 1)
                            )
                    }
                    
                    // Duration Toggle
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Include duration", isOn: $includeDuration)
                            .font(.headline)
                        
                        if includeDuration {
                            HStack {
                                Text("Duration:")
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                DurationPicker(duration: $duration)
                            }
                            .padding(.leading, 20)
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: saveLog) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save Log")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(project.isEmpty || description.isEmpty)
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .frame(width: 500, height: 600)
            .background(Color(.windowBackgroundColor))
        }
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
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            duration: includeDuration ? duration : nil
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

struct DurationPicker: View {
    @Binding var duration: TimeInterval
    
    @State private var hours = 0
    @State private var minutes = 0
    
    var body: some View {
        HStack(spacing: 8) {
            Picker("Hours", selection: $hours) {
                ForEach(0...23, id: \.self) { hour in
                    Text("\(hour)h").tag(hour)
                }
            }
            .frame(width: 60)
            
            Picker("Minutes", selection: $minutes) {
                ForEach(0...59, id: \.self) { minute in
                    Text("\(minute)m").tag(minute)
                }
            }
            .frame(width: 60)
        }
        .onChange(of: hours) { _ in updateDuration() }
        .onChange(of: minutes) { _ in updateDuration() }
        .onAppear { updateFromDuration() }
    }
    
    private func updateDuration() {
        duration = TimeInterval(hours * 3600 + minutes * 60)
    }
    
    private func updateFromDuration() {
        hours = Int(duration) / 3600
        minutes = Int(duration) % 3600 / 60
    }
}

#Preview {
    LoggingView()
}
