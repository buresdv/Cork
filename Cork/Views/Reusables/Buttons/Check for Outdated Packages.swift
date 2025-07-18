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

    var body: some View
    {
        Button
        {
            AppConstants.shared.logger.debug("Will manually check for package updates")
            
            appState.isCheckingForPackageUpdates = true
        } label: {
            Label("action.check-for-updates", systemImage: "arrow.clockwise")
        }
        .disabled(appState.isCheckingForPackageUpdates)
        .help("action.check-for-updates.help")
    }
}
