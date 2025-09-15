//
//  CountdownTimerView.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 15/09/2025.
//

import SwiftUI

struct CountdownTimerView: View {
    @ObservedObject var viewModel: CountdownTimerViewModel

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "hourglass")

            Text(viewModel.formattedTimeRemaining)
        }
    }
}
