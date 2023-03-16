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
