//
//  Upgrade Packages.swift
//  Cork
//
//  Created by David Bureš on 04.07.2022.
//

import Foundation
import SwiftUI

@MainActor
func upgradeBrewPackages(_ updateProgressTracker: UpdateProgressTracker) -> Void {
    Task {
        updateProgressTracker.updateProgress = 0
        
        updateProgressTracker.showUpdateSheet = true
        updateProgressTracker.updateStage = .updating
        let updateResult = await shell("/opt/homebrew/bin/brew", ["update"])!
        updateProgressTracker.updateProgress += 0.5
        
        updateProgressTracker.updateStage = .upgrading
        let upgradeResult = await shell("/opt/homebrew/bin/brew", ["upgrade"])!
        updateProgressTracker.updateProgress += 0.5
        updateProgressTracker.showUpdateSheet = false
    }
}
