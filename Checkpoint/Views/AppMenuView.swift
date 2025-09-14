//
//  AppMenuView.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 14/09/2025.
//

import SwiftUI

struct AppMenuView: View {

    // TODO: Do these want to be extracted to a view model?
    @State private var intervals: [Interval] = {
        var baseIntervals = [
            Interval(
                id: "15min",
                label: "15 Minutes",
                duration: .seconds(900),
                isSelected: false
            ),
            Interval(
                id: "30min",
                label: "30 Minutes",
                duration: .seconds(1800),
                isSelected: true
            ),
            Interval(
                id: "45min",
                label: "45 Minutes",
                duration: .seconds(2700),
                isSelected: false
            ),
            Interval(
                id: "60min",
                label: "60 Minutes",
                duration: .seconds(3600),
                isSelected: false
            ),
            Interval(
                id: "90min",
                label: "90 Minutes",
                duration: .seconds(5400),
                isSelected: false
            ),
        ]

        #if DEBUG
        baseIntervals
            .insert(
                Interval(
                    id: "1min",
                    label: "1 Minute",
                    duration: .seconds(60),
                    isSelected: false
                ),
                at: 0
            )
        #endif // DEBUG

        return baseIntervals
    }()

    var body: some View {
        Button(action: {
            // TODO:
        }) {
            Label("Add Log", systemImage: "plus")
        }

        Button(action: {
            // TODO:
        }) {
            Label("View Logs", systemImage: "list.dash")
        }

        Divider()

        Button(action: {
            // TODO:
        }) {
            Label("Start Timer", systemImage: "play.fill")
        }

        Button(action: {
            // TODO:
        }) {
            Label("Pause Timer", systemImage: "pause.fill")
        }

        Button(action: {
            // TODO:
        }) {
            Label("Stop Timer", systemImage: "stop.fill")
        }

        Divider()

        Menu {
            ForEach(intervals, id: \.id) { interval in
                Button(action: {
                    selectInterval(withID: interval.id)
                    #if DEBUG
                    print("Selected interval: \(interval.label)")
                    #endif // DEBUG
                }) {
                    HStack {
                        Text(interval.label)
                        Spacer()
                        if interval.isSelected {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Label("Change Interval", systemImage: "clock")
        }

        Divider()

        Button(action: {
            // TODO:
        }) {
            Label("Settings", systemImage: "gear")
        }

        Divider()

        Button(action: {
            // TODO:
        }) {
            Label("Quit Checkpoint", systemImage: "xmark.circle")
        }
    }

    private func selectInterval(withID id: String) {
        for index in intervals.indices {
            intervals[index].isSelected = (intervals[index].id == id)
        }
    }
}

#Preview {
    AppMenuView()
}
