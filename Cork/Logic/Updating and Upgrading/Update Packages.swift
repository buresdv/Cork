//
//  Update Packages.swift
//  Cork
//
//  Created by David Bureš on 09.03.2023.
//

import Foundation
import SwiftUI

@MainActor
func updatePackages(_ updateProgressTracker: UpdateProgressTracker) async -> PackageUpdateAvailability
{
    for await output in shell(AppConstants.brewExecutablePath.absoluteString, ["update"])
    {
        switch output
        {
        case let .standardOutput(outputLine):
            print("Update function output: \(outputLine)")
            updateProgressTracker.updateProgress = updateProgressTracker.updateProgress + 0.1

            if outputLine.starts(with: "Already up-to-date")
            {
                print("Inside update function: No updates available")
                return .noUpdatesAvailable
            }

        case let .standardError(errorLine):
            if errorLine.starts(with: "Another active Homebrew update process is already in progress") || errorLine == "Error: " || errorLine.contains("Updated [0-9]+ tap") || errorLine == "Already up-to-date" || errorLine.contains("No checksum defined")
            {
                updateProgressTracker.updateProgress = updateProgressTracker.updateProgress + 0.1
                print("Ignorable update function error: \(errorLine)")
            }
            else
            {
                print("Update function error: \(errorLine)")
                updateProgressTracker.errors.append("Update error: \(errorLine)")
            }
        }
    }
    updateProgressTracker.updateProgress = Float(10) / Float(2)

    return .updatesAvailable
}
