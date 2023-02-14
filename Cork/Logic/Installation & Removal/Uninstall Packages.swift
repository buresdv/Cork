//
//  Uninstall Packages.swift
//  Cork
//
//  Created by David Bureš on 05.02.2023.
//

import Foundation
import SwiftUI

@MainActor
func uninstallSelectedPackage(package: BrewPackage, brewData: BrewDataStorage, appState: AppState) async -> Void
{
    appState.isShowingUninstallationProgressView = true
    
    print("Will try to remove package \(package.name)")
    let uninstallCommandOutput = await shell("/opt/homebrew/bin/brew", ["uninstall", package.name])
    
    print(uninstallCommandOutput.standardError)
    
    if uninstallCommandOutput.standardError.contains("because it is required by")
    {
        print("Could not uninstall this package because it's a dependency")
        
        let dependencyNameExtractionRegex: String = "(?<=required by ).*?(?=,)"
        
        var dependencyName: String
        
        guard let matchedRange = uninstallCommandOutput.standardError.range(of: dependencyNameExtractionRegex, options: .regularExpression) else { dependencyName = "FAILED TO GET DEPENDENCY NAME"; return }
        
        dependencyName = String(uninstallCommandOutput.standardError[matchedRange])
        
        appState.offendingDependencyProhibitingUninstallation = dependencyName
        appState.isShowingUninstallationNotPossibleDueToDependencyAlert = true
        
        print("Name of offending dependency: \(dependencyName)")
        
    }
    else
    {
        print("Uninstalling can proceed")
        
        switch package.isCask
        {
        case false:
            DispatchQueue.main.async
            {
                withAnimation
                {
                    brewData.installedFormulae.removeAll(where: { $0.name == package.name })
                }
            }

        case true:
            DispatchQueue.main.async
            {
                withAnimation
                {
                    brewData.installedCasks.removeAll(where: { $0.name == package.name })
                }
            }
        }
    }
    
    appState.isShowingUninstallationProgressView = false

    print(uninstallCommandOutput)
}
