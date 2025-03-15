//
//  Outdated Package.swift
//  Cork
//
//  Created by David Bureš on 05.04.2023.
//

import Foundation

struct OutdatedPackage: Identifiable, Equatable, Hashable
{
    enum PackageUpdatingType
    {
        /// The package is updating through Homebrew
        case homebrew
        
        /// The package updates itself
        case selfUpdating
    }
    
    let id: UUID = .init()

    let package: BrewPackage

    let installedVersions: [String]
    let newerVersion: String

    var isMarkedForUpdating: Bool = true
    
    var updatingManagedBy: PackageUpdatingType
}
