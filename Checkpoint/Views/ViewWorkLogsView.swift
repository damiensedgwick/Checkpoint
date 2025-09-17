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
            }
        }
    }
}

#Preview {
    ViewWorkLogsView()
        .frame(width: 500, height: 300)
}
