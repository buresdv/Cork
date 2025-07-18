//
//  Check for Outdated Packages.swift
//  Cork
//
//  Created by David Bureš - P on 15.07.2025.
//

import SwiftUI

struct CheckForOutdatedPackagesButton: View
{
    @EnvironmentObject var appState: AppState

    var body: some View
    {
        Button
        {
            appState.isCheckingForPackageUpdates = true
        } label: {
            Label("action.check-for-updates", systemImage: "arrow.clockwise")
        }
        .disabled(appState.isCheckingForPackageUpdates)
        .help("action.check-for-updates.help")
    }
}
