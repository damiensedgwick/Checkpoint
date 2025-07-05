//
//  AddLogsView.swift
//  checkpoint
//
//  Created by Damien Sedgwick on 05/07/2025.
//

import SwiftUI

struct LoggingView: View {
    var body: some View {
        VStack {
            Text("Logging Window")
                .font(.title)
            // Your logging UI here
        }
        .frame(minWidth: 400, minHeight: 300)
        .padding()
    }
}

#Preview {
    LoggingView()
}
