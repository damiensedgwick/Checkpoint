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
            Text("View Work Logs View")
                .font(.body)
                .fontWeight(.bold)

            if viewModel.logEntries.isEmpty {
                Text("No log entries found")
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    ViewWorkLogsView()
        .frame(width: 200, height: 200)
}
