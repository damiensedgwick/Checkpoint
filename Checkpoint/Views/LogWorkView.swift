//
//  ContentView.swift
//  checkpoint
//
//  Created by Damien Sedgwick on 13/09/2025.
//

import SwiftUI

struct LogWorkView: View {
    @State private var project = ""
    @State private var title = ""
    @State private var description = ""

    var body: some View {
        VStack {
            VStack {
                Image(systemName: "note.text.badge.plus")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.secondary, .primary)
                    .font(.largeTitle)

                Text("Log work")
                    .font(.title)
            }


            Spacer()

            VStack {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Project")
                            .font(.headline)
                        TextField("", text: $project)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Title")
                            .font(.headline)
                        TextField("", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Description")
                            .font(.headline)
                        TextEditor(text: $description)
                            .frame(height: 60)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 6)
                            .background(Color(.textBackgroundColor))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.separatorColor), lineWidth: 1)
                            )
                    }
                }
                .padding()
            }

            Spacer()

            VStack {
                HStack(spacing: 12) {
                    Button("Cancel") {
                        // TODO: Add logic here
                    }
                    .buttonStyle(.borderless)

                    Button("Log Work") {
                        // TODO: Add logic here
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .frame(width: 300, height: 400)
    }
}

#Preview {
    LogWorkView()
        .frame(width: 300, height: 400)
}
