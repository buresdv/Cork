//
//  Install Selected Packages.swift
//  Cork
//
//  Created by David Bureš on 04.07.2022.
//

import Foundation

@MainActor
func installSelectedPackages(packageArray: [String], tracker: InstallationProgressTracker) -> Void {
    let progressSteps: Float = Float(1) / Float(packageArray.count)
    
    tracker.progressNumber = 0
    
    for package in packageArray {
        Task {
            tracker.packageBeingCurrentlyInstalled = package
            print(tracker.packageBeingCurrentlyInstalled)
            
            await shell("/opt/homebrew/bin/brew", ["install", package])
            
            tracker.progressNumber += progressSteps
            print("Installing \(tracker.packageBeingCurrentlyInstalled) at \(tracker.progressNumber)")
        }
    }
}
