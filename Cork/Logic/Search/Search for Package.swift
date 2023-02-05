//
//  Search for Package.swift
//  Cork
//
//  Created by David Bureš on 05.02.2023.
//

import Foundation

func searchForPackage(packageName: String, packageType: PackageType) async throws -> [String]
{
    var finalPackageArray: [String]

    switch packageType
    {
    case .formula:
        let foundFormulae = await Task
        {
            await shell("/opt/homebrew/bin/brew", ["search", "--formulae", packageName])!
        }.result

        finalPackageArray = try foundFormulae.get().components(separatedBy: "\n")

    case .cask:
        let foundCasks = await Task
        {
            await shell("/opt/homebrew/bin/brew", ["search", "--casks", packageName])!
        }.result

        finalPackageArray = try foundCasks.get().components(separatedBy: "\n")
    }

    return finalPackageArray
}
