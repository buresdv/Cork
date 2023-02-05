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
    
    switch packageType {
    case .formula:
        var foundFormulae = await Task {
            return await shell("/opt/homebrew/bin/brew", ["search", "--formulae", packageName])!
        }.result
        
        finalPackageArray = try foundFormulae.get().components(separatedBy: "\n")
        
    case .cask:
        var foundCasks = await Task {
            return await shell("/opt/homebrew/bin/brew", ["search", "--casks", packageName])!
        }.result
        
        finalPackageArray = try foundCasks.get().components(separatedBy: "\n")
    }
    
    return finalPackageArray
}
