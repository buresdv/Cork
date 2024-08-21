//
//  Outdated Package.swift
//  Cork
//
//  Created by David Bureš on 05.04.2023.
//

import Foundation

struct OutdatedPackage: Identifiable, Equatable, Hashable
{
    let id: UUID = .init()

    let package: BrewPackage

    let installedVersions: [String]
    let newerVersion: String

    var isMarkedForUpdating: Bool = true
}
