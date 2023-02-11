//
//  Install Progress Tracker.swift
//  Cork
//
//  Created by David Bureš on 04.07.2022.
//

import SwiftUI

struct InstallProgressTrackerView: View {
    @Binding var progress: Float
    @Binding var currentlyInstallingPackage: String

    var body: some View {
        VStack {
            ProgressView(value: progress)
            Text("Installing \(currentlyInstallingPackage)")
        }
        .padding()
    }
}
