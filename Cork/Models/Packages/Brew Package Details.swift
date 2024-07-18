//
//  Brew Package Details.swift
//  Cork
//
//  Created by David Bureš on 18.07.2024.
//

import Foundation

struct BrewPackageDetails: Hashable
{
    /// Name of the package
    let name: String
    
    let description: String
    
    var homepage: URL
    var tap: BrewTap
    var installedAsDependency: Bool
    var packageDependents: [String]?
    var dependencies: [BrewPackageDependency]?
    var outdated: Bool
    var caveats: String?
    var pinned: Bool?
    
    mutating func loadDependants() async
    {
        let packageDependentsRaw: String = await shell(AppConstants.brewExecutablePath, ["uses", "--installed", self.name]).standardOutput
        
        packageDependents = packageDependentsRaw.components(separatedBy: "\n").dropLast()
    }
}
