//
//  Install Selected Packages.swift
//  Cork
//
//  Created by David Bureš on 04.07.2022.
//

import Foundation
import SwiftUI

@MainActor
func installSelectedPackages(packageArray: [String], tracker: InstallationProgressTracker) -> Void {
    let progressSteps: Float = Float(1) / Float(packageArray.count)
    
    tracker.progressNumber = 0
    
    for package in packageArray {
        Task {
            tracker.packageBeingCurrentlyInstalled = package
            print(tracker.packageBeingCurrentlyInstalled)
            
            let installCommandOutput = await shell("/opt/homebrew/bin/brew", ["install", package])
            
            if installCommandOutput!.contains("was successfully installed") {
                tracker.progressNumber += progressSteps
            } else {
                tracker.isShowingInstallationFailureAlert = true
            }
        
            print("Installing \(tracker.packageBeingCurrentlyInstalled) at \(tracker.progressNumber)")
        }
    }
}
