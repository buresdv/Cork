//
//  Search for Package.swift
//  Cork
//
//  Created by David Bureš on 05.02.2023.
//

import Foundation

func searchForPackage(_ packageName: String, of packageType: PackageType, withVersion version: String?) async throws -> [String]
{
    var finalPackageArray: [String]
    
    var searchArg = getSearchArg(from: packageName, with: version)

    switch packageType
    {
    case .formula:
        print("Search arg: \(searchArg)")
        let foundFormulae = await shell(AppConstants.brewExecutablePath, ["search", "--formulae", searchArg])

        finalPackageArray = foundFormulae.standardOutput.components(separatedBy: "\n")

    case .cask:
        print("Search arg: \(searchArg)")
        let foundCasks = await shell(AppConstants.brewExecutablePath, ["search", "--casks", searchArg])

        finalPackageArray = foundCasks.standardOutput.components(separatedBy: "\n")
    }

    finalPackageArray.removeLast()
    
    print("Search found these: \(finalPackageArray)")
    
    return finalPackageArray
}

private func getSearchArg(from packageName: String, with version: String?) -> String
{
    var searchPackageName = packageName

    if let version = version, !version.isEmpty
    {
        // won't do version regex checking here

        let packageNameComponents = packageName.components(separatedBy: "@")
        
        if (packageNameComponents.count > 0)
        {
            searchPackageName = packageNameComponents[0]  // truncate user's `@` input
        }

        return "\(searchPackageName)@\(version)"
    }

    return searchPackageName
}
