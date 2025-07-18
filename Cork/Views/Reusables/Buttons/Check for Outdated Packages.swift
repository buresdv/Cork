//
//  Check for Outdated Packages.swift
//  Cork
//
//  Created by David Bureš - P on 15.07.2025.
//

import SwiftUI
import CorkShared

struct CheckForOutdatedPackagesButton: View
{
    @Environment(AppState.self) var appState: AppState
    @EnvironmentObject var outdatedPackagesTracker: OutdatedPackageTracker

    var body: some View
    {
        Button
        {
            outdatedPackagesTracker.checkForUpdates()
        } label: {
            Label("action.check-for-updates", systemImage: "arrow.clockwise")
        }
        .disabled(outdatedPackagesTracker.outdatedPackageDisplayStage == .checkingForUpdates)
        .help("action.check-for-updates.help")
    }
}
