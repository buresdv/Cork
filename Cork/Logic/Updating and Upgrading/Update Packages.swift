//
//  Upgrade Packages.swift
//  Cork
//
//  Created by David Bureš on 04.07.2022.
//

import Foundation
import SwiftUI

@MainActor
func updatePackages(_ updateProgressTracker: UpdateProgressTracker, appState _: AppState, outdatedPackageTracker _: OutdatedPackageTracker, detailStage: UpdatingProcessDetails? = nil) async
{
    for await output in shell(AppConstants.brewExecutablePath, ["upgrade"])
    {
        switch output
        {
        case let .standardOutput(outputLine):
            print("Upgrade function output: \(outputLine)")
                
            if let detailStage
            {
                if outputLine.contains("Downloading")
                {
                    detailStage.currentStage = .downloading
                }
                else if outputLine.contains("Pouring")
                {
                    detailStage.currentStage = .pouring
                }
                else if outputLine.contains("cleanup")
                {
                    detailStage.currentStage = .cleanup
                }
                else if outputLine.contains("Backing App")
                {
                    detailStage.currentStage = .backingUp
                }
                else if outputLine.contains("Moving App") || outputLine.contains("Linking")
                {
                    detailStage.currentStage = .linking
                }
                else
                {
                    detailStage.currentStage = .cleanup
                }
            }
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
