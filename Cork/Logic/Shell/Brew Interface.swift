//
//  Brew Interface.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation
import SwiftUI

struct SearchResults
{
    let foundFormulae: [String]
    let foundCasks: [String]
}

func getListOfFoundPackages(searchWord: String) async -> String
{
    var parsedResponse: String?
    parsedResponse = await shell(AppConstants.brewExecutablePath.absoluteString, ["search", searchWord]).standardOutput

    return parsedResponse!
}

enum OutdatedPackageRetrievalError: Error
{
    case homeNotSet, otherError
}

/// Get a list of all outdated packages. Optionally supply array of package names to skip asking Homebrew for a new list of packages.
func getListOfUpgradeablePackages(brewData: BrewDataStorage, packageArray: [String]? = nil) async throws -> [OutdatedPackage]
{
    
    var outdatedPackageTracker: [OutdatedPackage] = .init()
    
    do
    {
        var outdatedPackages: [String] = .init()
        
        /// Check if we have supplied a list of outdated package names. If not, retrieve a new one
        if let packageArray
        {
            outdatedPackages = packageArray
        }
        else
        {
            outdatedPackages = try await getListOfAllUpgradeablePackageNames()
        }
        
        for outdatedPackage in outdatedPackages {
            if let foundOutdatedFormula = await brewData.installedFormulae.filter({ $0.name == outdatedPackage }).first
            {
                if foundOutdatedFormula.installedIntentionally /// Only show the intentionally-installed packages. The users don't care about dependencies
                {
                    outdatedPackageTracker.append(OutdatedPackage(package: foundOutdatedFormula))
                }
            }
            if let foundOutdatedCask = await brewData.installedCasks.filter({ $0.name == outdatedPackage }).first
            {
                if foundOutdatedCask.installedIntentionally
                {
                    outdatedPackageTracker.append(OutdatedPackage(package: foundOutdatedCask))
                }
            }
        }
        
        return outdatedPackageTracker
    }
    catch
    {
        throw OutdatedPackageRetrievalError.homeNotSet
    }
}
func getListOfAllUpgradeablePackageNames() async throws -> [String]
{
    let outdatedPackagesCommandOutput: TerminalOutput = await shell(AppConstants.brewExecutablePath.absoluteString, ["outdated"])
    let outdatedPackagesRaw: String = outdatedPackagesCommandOutput.standardOutput
    
    print("Outdated packages output: \(outdatedPackagesCommandOutput)")
    
    if outdatedPackagesCommandOutput.standardError.contains("HOME must be set")
    {
        print("Encountered HOME error")
        throw OutdatedPackageRetrievalError.homeNotSet
    }
    
    print("All outdated packages output: \(outdatedPackagesRaw)")
    
    let outdatedPackages: [String] = outdatedPackagesRaw.components(separatedBy: "\n")
    
    // Check if the last package has an empty name. If it does, remove it. Otherwise return the tracker
    // A fix for the last package being empty came out in Brew 4, but some people might not be upgraded to it, hence the need for this check
    return outdatedPackages.last == "" ? outdatedPackages.dropLast() : outdatedPackages
}

func addTap(name: String) async -> String
{
    let tapResult = await shell(AppConstants.brewExecutablePath.absoluteString, ["tap", name]).standardError
    
    print("Tapping result: \(tapResult)")
    
    return tapResult
}

enum UntapError: Error
{
    case couldNotUntap
}

@MainActor
func removeTap(name: String, availableTaps: AvailableTaps, appState: AppState, shouldApplyUninstallSpinnerToRelevantItemInSidebar: Bool = false) async throws -> Void
{
    
    var indexToReplaceGlobal: Int? = nil
    
    if shouldApplyUninstallSpinnerToRelevantItemInSidebar
    {
        if let indexToReplace = availableTaps.addedTaps.firstIndex(where: { $0.name == name })
        {
            availableTaps.addedTaps[indexToReplace].changeBeingModifiedStatus()
            
            indexToReplaceGlobal = indexToReplace
        }
    }
    else
    {
        appState.isShowingUninstallationProgressView = true
    }
    
    let untapResult = await shell(AppConstants.brewExecutablePath.absoluteString, ["untap", name]).standardError
    print("Untapping result: \(untapResult)")
    
    defer
    {
        appState.isShowingUninstallationProgressView = false
    }
    
    if untapResult.contains("Untapped")
    {
        print("Untapping was successful")
        DispatchQueue.main.async {
            withAnimation {
                availableTaps.addedTaps.removeAll(where: { $0.name == name })
            }
        }
        
        if appState.navigationSelection != nil
        {
            appState.navigationSelection = nil
        }
    }
    else
    {
        print("Untapping failed")
        
        if untapResult.contains("because it contains the following installed formulae or casks")
        {
            appState.offendingTapProhibitingRemovalOfTap = name
            appState.fatalAlertType = .couldNotRemoveTapDueToPackagesFromItStillBeingInstalled
            appState.isShowingFatalError = true
        }
        
        if let indexToReplaceGlobal
        {
            availableTaps.addedTaps[indexToReplaceGlobal].changeBeingModifiedStatus()
        }
        else
        {
            print("Could not get index for that tap. Will loop over all of them")
            for (index, _) in availableTaps.addedTaps.enumerated()
            {
                if availableTaps.addedTaps[index].isBeingModified
                {
                    availableTaps.addedTaps[index].isBeingModified = false
                }
            }
        }
        
        throw UntapError.couldNotUntap
    }
}
