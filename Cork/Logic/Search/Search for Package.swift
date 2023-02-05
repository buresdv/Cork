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
        
        let foundFormulae = await shell("/opt/homebrew/bin/brew", ["search", "--formulae", packageName])!

        finalPackageArray = foundFormulae.components(separatedBy: "\n")

    case .cask:
        
        let foundCasks = await shell("/opt/homebrew/bin/brew", ["search", "--casks", packageName])!

        finalPackageArray = foundCasks.components(separatedBy: "\n")
    }

    finalPackageArray.removeLast()
    
    print("Search found these: \(finalPackageArray)")
    
    return finalPackageArray
}
