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

func getListOfUpgradeablePackages(brewData: BrewDataStorage) async throws -> [OutdatedPackage]
{
    var outdatedPackageTracker: [OutdatedPackage] = .init()
    
    let outdatedPackagesCommandOutput: TerminalOutput = await shell(AppConstants.brewExecutablePath.absoluteString, ["outdated"])
    let outdatedPackagesRaw: String = outdatedPackagesCommandOutput.standardOutput
    
    print("Outdatedpackages output: \(outdatedPackagesCommandOutput)")
    
    if outdatedPackagesCommandOutput.standardError.contains("HOME must be set")
    {
        print("Encountered HOME error")
        throw OutdatedPackageRetrievalError.homeNotSet
    }
    
    print("Outdated packages output: \(outdatedPackagesRaw)")
    
    let outdatedPackages = outdatedPackagesRaw.components(separatedBy: "\n")
    
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
    
    // Check if the last package has an empty name. If it does, remove it. Otherwise return the tracker
    // A fix for the last package being empty came out in Brew 4, but some people might not be upgraded to it, hence the need for this check
    return outdatedPackageTracker.last?.package.name == "" ? outdatedPackageTracker.dropLast() : outdatedPackageTracker
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
func removeTap(name: String, availableTaps: AvailableTaps, appState: AppState) async throws -> Void
{
    appState.isShowingUninstallationProgressView = true
    
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
        
        throw UntapError.couldNotUntap
    }
}
