//
//  Update Packages.swift
//  Cork
//
//  Created by David Bureš on 09.03.2023.
//

import Foundation
import SwiftUI

@MainActor
func updatePackages(_ updateProgressTracker: UpdateProgressTracker, appState: AppState) async -> PackageUpdateAvailability
{
    appState.isShowingUpdateSheet = true

    var updateAvailability: PackageUpdateAvailability = .updatesAvailable

    for await output in shell("/opt/homebrew/bin/brew", ["update"])
    {
        switch output
        {
        case let .standardOutput(outputLine):
            print("Update function output: \(outputLine)")
            updateProgressTracker.updateProgress = updateProgressTracker.updateProgress + 0.1

            if outputLine.contains("Already up-to-date")
            {
                updateAvailability = .noUpdatesAvailable
            }

        case let .standardError(errorLine):
            print("Update function error: \(errorLine)")
            updateProgressTracker.errors.append("⚠️ Update error: \(errorLine)")
        }
    }
    updateProgressTracker.updateProgress = Float(10) / Float(2)

    return updateAvailability
}
