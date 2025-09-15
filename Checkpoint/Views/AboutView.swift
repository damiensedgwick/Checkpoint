//
//  AboutView.swift
//  Checkpoint
//
//  Created by Damien Sedgwick on 15/09/2025.
//

import SwiftUI

struct AboutView: View {
    let onClose: () -> Void

    init(onClose: @escaping () -> Void = {}) {
        self.onClose = onClose
    }

    var body: some View {
        VStack {
            Spacer()

            Image("AppIconImage")
                .resizable()
                .frame(width: 125, height: 125)
                .clipShape(RoundedRectangle(cornerRadius: 20))

            Spacer()

            VStack {

                VStack(spacing: 4) {
                    Text("Checkpoint")
                        .font(.body)
                        .fontWeight(.bold)

                    Text("Track your tasks with ease")
                        .font(.body)
                        .multilineTextAlignment(.center)

                    Text("Checkpoint version \(appVersion)")
                        .font(.caption)
                }

                Spacer()

                VStack {
                    Text("© 2025 Damien Sedgwick")
                        .font(.footnote)
                        .multilineTextAlignment(.center)

                    Text("Released under the MIT License")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }

            Spacer()
        }
        .frame(width: 200, height: 300)
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

#Preview {
    AboutView()
        .frame(width: 200, height: 280)
}
