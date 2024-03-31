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
    parsedResponse = await shell(AppConstants.brewExecutablePath, ["search", searchWord]).standardOutput

    return parsedResponse!
}

enum OutdatedPackageRetrievalError: Error
{
    case homeNotSet, otherError
}

/// Get a list of all outdated packages. Optionally supply array of package names to skip asking Homebrew for a new list of packages.
func getListOfUpgradeablePackages(brewData: BrewDataStorage, packageArray: [String]? = nil) async throws -> Set<OutdatedPackage>
{
    
    var outdatedPackageTracker: Set<OutdatedPackage> = .init()

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
                outdatedPackageTracker.insert(OutdatedPackage(package: foundOutdatedFormula))
            }
            if let foundOutdatedCask = await brewData.installedCasks.filter({ $0.name == outdatedPackage }).first
            {
                if foundOutdatedCask.installedIntentionally
                {
                    outdatedPackageTracker.insert(OutdatedPackage(package: foundOutdatedCask))
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
    let outdatedPackagesCommandOutput: TerminalOutput = await shell(AppConstants.brewExecutablePath, ["outdated"])
    let outdatedPackagesRaw: String = outdatedPackagesCommandOutput.standardOutput
    
    AppConstants.logger.info("Outdated packages Standard output: \(outdatedPackagesCommandOutput.standardOutput)\nStandard error: \(outdatedPackagesCommandOutput.standardError)")
    
    if outdatedPackagesCommandOutput.standardError.contains("HOME must be set")
    {
        AppConstants.logger.error("Encountered HOME error")
        throw OutdatedPackageRetrievalError.homeNotSet
    }
    
    AppConstants.logger.log("All outdated packages output: \(outdatedPackagesRaw, privacy: .public)")
    
    let outdatedPackages: [String] = outdatedPackagesRaw.components(separatedBy: "\n")
    
    // Check if the last package has an empty name. If it does, remove it. Otherwise return the tracker
    // A fix for the last package being empty came out in Brew 4, but some people might not be upgraded to it, hence the need for this check
    return outdatedPackages.last == "" ? outdatedPackages.dropLast() : outdatedPackages
}
