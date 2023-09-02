//
//  Uninstall Packages.swift
//  Cork
//
//  Created by David Bureš on 05.02.2023.
//

import Foundation
import SwiftUI

@MainActor
func uninstallSelectedPackage(package: BrewPackage, brewData: BrewDataStorage, appState: AppState, shouldRemoveAllAssociatedFiles: Bool, shouldApplyUninstallSpinnerToRelevantItemInSidebar: Bool = false) async throws
{
    
    var indexToReplaceGlobal: Int?
    
    if shouldApplyUninstallSpinnerToRelevantItemInSidebar
    {
        if !package.isCask
        {
            if let indexToReplace = brewData.installedFormulae.firstIndex(where: { $0.name == package.name })
            {
                brewData.installedFormulae[indexToReplace].changeBeingModifiedStatus()
                
                indexToReplaceGlobal = indexToReplace
            }
            
        }
        else
        {
            if let indextoReplace = brewData.installedCasks.firstIndex(where: { $0.name == package.name })
            {
                brewData.installedCasks[indextoReplace].changeBeingModifiedStatus()
                
                indexToReplaceGlobal = indextoReplace
            }
        }
    }
    else
    {
        appState.isShowingUninstallationProgressView = true
    }

    print("Will try to remove package \(package.name)")
    var uninstallCommandOutput: TerminalOutput
    
    if !shouldRemoveAllAssociatedFiles
    {
        uninstallCommandOutput = await shell(AppConstants.brewExecutablePath.absoluteString, ["uninstall", package.name])
    }
    else
    {
        uninstallCommandOutput = await shell(AppConstants.brewExecutablePath.absoluteString, ["uninstall", "--zap", package.name])
    }

    print(uninstallCommandOutput.standardError)

    if uninstallCommandOutput.standardError.contains("because it is required by")
    {
        print("Could not uninstall this package because it's a dependency")

        /// If the uninstallation failed, change the status back to "not being modified"
        if !package.isCask
        {
            /// Take the index gotten at the top. If it doesn't exist, loop over all packages and force-change them all to `false`
            if let indexToReplaceGlobal
            {
                brewData.installedFormulae[indexToReplaceGlobal].changeBeingModifiedStatus()
            }
            else
            {
                print("Could not get the index for that formula. Will loop over all of them.")
                
                for (index, _) in brewData.installedFormulae.enumerated()
                {
                    if brewData.installedFormulae[index].isBeingModified == true
                    {
                        brewData.installedFormulae[index].isBeingModified = false
                    }
                }
            }
        }
        else
        {
            /// See above, it's the same thing, but for casks
            if let indexToReplaceGlobal
            {
                brewData.installedCasks[indexToReplaceGlobal].changeBeingModifiedStatus()
            }
            else
            {
                print("Could not get the index for that cask. Will loop over all of them.")
                
                for (index, _) in brewData.installedCasks.enumerated()
                {
                    if brewData.installedCasks[index].isBeingModified == true
                    {
                        brewData.installedCasks[index].isBeingModified = false
                    }
                }
            }
        }
        
        do
        {
            let dependencyNameExtractionRegex: String = "(?<=required by ).*?(?=, which)"

            var dependencyName: String

            dependencyName = String(try regexMatch(from: uninstallCommandOutput.standardError, regex: dependencyNameExtractionRegex))

            appState.offendingDependencyProhibitingUninstallation = dependencyName
            appState.fatalAlertType = .uninstallationNotPossibleDueToDependency
            appState.isShowingFatalError = true

            print("Name of offending dependency: \(dependencyName)")
        }
        catch let regexError as NSError
        {
            print("Failed to extract dependency name from output: \(regexError)")
            throw RegexError.regexFunctionCouldNotMatchAnything
        }
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
        
        if appState.navigationSelection != nil
        {
            appState.navigationSelection = nil
        }
    }

    appState.isShowingUninstallationProgressView = false

    print(uninstallCommandOutput)
}
