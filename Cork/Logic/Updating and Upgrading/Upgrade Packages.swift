//
//  Upgrade Packages.swift
//  Cork
//
//  Created by David Bureš on 04.07.2022.
//

import Foundation
import SwiftUI

@MainActor
func upgradePackages(_ updateProgressTracker: UpdateProgressTracker, appState _: AppState, outdatedPackageTracker: OutdatedPackageTracker) async
{
    for await output in shell("/opt/homebrew/bin/brew", ["upgrade"])
    {
        switch output
        {
        case let .standardOutput(outputLine):
            print("Upgrade function output: \(outputLine)")
            updateProgressTracker.updateProgress = updateProgressTracker.updateProgress + 0.1

            if outputLine.contains("Upgrading")
            {
                do
                {
                    let packageBeingUpgraded: String = try regexMatch(from: outputLine, regex: "(?<=Upgrading ).*?(?=\n)")

                    if packageBeingUpgraded != "FAILED TO FIND MATCH"
                    {
                        print("Package being upgraded: \(packageBeingUpgraded)")
                        outdatedPackageTracker.outdatedPackageNames = outdatedPackageTracker.outdatedPackageNames.filter({ $0 != packageBeingUpgraded })
                    }
                }
                catch let regexMatchError as NSError
                {
                    print("Regex matching error: \(regexMatchError)")
                }
            }

        case let .standardError(errorLine):
            print("Upgrade function error: \(errorLine)")
            updateProgressTracker.errors.append("⚠️ Upgrade error: \(errorLine)")
        }
    }

    updateProgressTracker.updateProgress = 10
}

/*
 @MainActor
 func updateBrewPackages(_ updateProgressTracker: UpdateProgressTracker, appState: AppState)
 {
     Task
     {
         updateProgressTracker.updateProgress = 0

         appState.isShowingUpdateSheet = true
         updateProgressTracker.updateStage = .updating
         updateProgressTracker.updateProgress += 0.2
         let updateResult = await shell(AppConstants.brewExecutablePath.absoluteString, ["update"]).standardOutput
         updateProgressTracker.updateProgress += 0.3

         print("Update result: \(updateResult)")

         updateProgressTracker.updateStage = .upgrading
         updateProgressTracker.updateProgress += 0.2
         let upgradeResult = await shell(AppConstants.brewExecutablePath.absoluteString, ["upgrade"]).standardOutput
         updateProgressTracker.updateProgress += 0.3

         print("Upgrade result: \(upgradeResult)")

         appState.isShowingUpdateSheet = false
     }
 }
 */
