//
//  Upgrade Packages.swift
//  Cork
//
//  Created by David Bureš on 04.07.2022.
//

import Foundation
import SwiftUI

@MainActor
func upgradePackages(_ updateProgressTracker: UpdateProgressTracker, appState _: AppState, outdatedPackageTracker _: OutdatedPackageTracker) async
{
    for await output in shell(AppConstants.brewExecutablePath.absoluteString, ["upgrade"])
    {
        switch output
        {
        case let .standardOutput(outputLine):
            print("Upgrade function output: \(outputLine)")
            updateProgressTracker.updateProgress = updateProgressTracker.updateProgress + 0.1

        case let .standardError(errorLine):
            if errorLine.contains("tap") || errorLine.contains("No checksum defined for")
            {
                updateProgressTracker.updateProgress = updateProgressTracker.updateProgress + 0.1

                print("Ignorable upgrade function error: \(errorLine)")
            }
            else
            {
                print("Upgrade function error: \(errorLine)")
                updateProgressTracker.errors.append("Upgrade error: \(errorLine)")
            }
        }
    }

    updateProgressTracker.updateProgress = 9
}
