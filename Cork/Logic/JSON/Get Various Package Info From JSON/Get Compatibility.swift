//
//  Get Compatibility.swift
//  Cork
//
//  Created by David Bureš on 20.09.2023.
//

import Foundation
import SwiftyJSON

enum CompatibilityCheckingError: Error
{
    case isCask
}

/// Check if a package is compatible with a particular macOS version
func getPackageCompatibilityFromJSON(json: JSON, package: BrewPackage) throws -> Bool
{
    if !package.isCask
    {
        var checkingResult: Bool = false

        do
        {
            let availableVersions: [String] = try getCompatibleVersionsForFormula(json: json, package: package)

            for systemVersion in availableVersions
            {
                print("Available version: \(systemVersion)")
                if systemVersion.contains(AppConstants.osVersionString.lookupName)
                {
                    print("\(package.name) is compatible with \(AppConstants.osVersionString.fullName)")
                    checkingResult = true
                    break
                }
            }
        }
        catch let compatibleVersionsRetrievalError
        {
            throw compatibleVersionsRetrievalError
        }

        if checkingResult == false
        {
            print("\(package.name) is not compatible with \(AppConstants.osVersionString.lookupName)")
        }

        return checkingResult
    }
    else
    {
        throw CompatibilityCheckingError.isCask
    }
}

enum CompatibleVersionsRetrievalError: Error
{
    case isCask
}

/// Retrieve macOS versions for a formula
func getCompatibleVersionsForFormula(json: JSON, package: BrewPackage) throws -> [String]
{
    if package.isCask
    {
        throw CompatibleVersionsRetrievalError.isCask
    }

    var versionsTracker: [String] = .init()

    let availableFiles = json["formulae", 0, "bottle", "stable", "files"]

    for version in availableFiles
    {
        versionsTracker.append(version.0)
    }

    return versionsTracker
}
