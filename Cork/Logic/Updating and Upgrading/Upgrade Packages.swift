//
//  Upgrade Packages.swift
//  Cork
//
//  Created by David Bureš on 04.07.2022.
//

import Foundation
import SwiftUI

func upgradePackages() async -> Void
{
    for await output in shell("/opt/homebrew/bin/brew", ["upgrade"])
    {
        switch output
        {
            case let .standardOutput(outputLine):
                print("Upgrade function output: \(outputLine)")
                
            case let .standardError(errorLine):
                print("Upgrade function error: \(errorLine)")
                
        }
    }
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
        let updateResult = await shell("/opt/homebrew/bin/brew", ["update"]).standardOutput
        updateProgressTracker.updateProgress += 0.3
        
        print("Update result: \(updateResult)")

        updateProgressTracker.updateStage = .upgrading
        updateProgressTracker.updateProgress += 0.2
        let upgradeResult = await shell("/opt/homebrew/bin/brew", ["upgrade"]).standardOutput
        updateProgressTracker.updateProgress += 0.3
        
        print("Upgrade result: \(upgradeResult)")

        appState.isShowingUpdateSheet = false
    }
}
*/
