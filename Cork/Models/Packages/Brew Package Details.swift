//
//  Brew Package Details.swift
//  Cork
//
//  Created by David Bureš on 18.07.2024.
//

import Foundation

struct BrewPackageDetails: Hashable, Sendable
{
    /// Name of the package
    let name: String
    
    let description: String
    
    var homepage: URL
    var tap: BrewTap
    var installedAsDependency: Bool
    var dependencies: [BrewPackageDependency]?
    var outdated: Bool
    var caveats: String?
    var pinned: Bool?
}
