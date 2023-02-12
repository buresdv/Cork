//
//  Install Selected Packages.swift
//  Cork
//
//  Created by David Bureš on 04.07.2022.
//

import Foundation

@MainActor
func installSelectedPackages(packageArray: [String], tracker: InstallationProgressTracker, brewData: BrewDataStorage) -> Void
{
    let progressSteps = Float(1) / Float(packageArray.count)
    print(progressSteps)

    tracker.progressNumber = 0

    for package in packageArray
    {
        Task
        {
            tracker.packageBeingCurrentlyInstalled = package
            print("Trying to install \(tracker.packageBeingCurrentlyInstalled)")

            let installCommandOutput = await shell("/opt/homebrew/bin/brew", ["install", package])

            if installCommandOutput.standardOutput.contains("Pouring")
            {
                print("Installing \(tracker.packageBeingCurrentlyInstalled) at \(tracker.progressNumber)")
                tracker.progressNumber += progressSteps
            }
            else
            {
                tracker.isShowingInstallationFailureAlert = true
            }
            
        }
    }
}
