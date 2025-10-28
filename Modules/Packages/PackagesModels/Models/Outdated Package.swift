//
//  Outdated Package.swift
//  Cork
//
//  Created by David Bureš - P on 28.10.2025.
//

import Foundation

public struct OutdatedPackage: Identifiable, Equatable, Hashable
{
    enum PackageUpdatingType
    {
        /// The package is updating through Homebrew
        case homebrew

        /// The package updates itself
        case selfUpdating

        var argument: String
        {
            switch self
            {
            case .homebrew:
                return .init()
            case .selfUpdating:
                return "--greedy"
            }
        }
    }

    public let id: UUID = .init()

    let package: BrewPackage

    let installedVersions: [String]
    let newerVersion: String

    var isMarkedForUpdating: Bool = true

    var updatingManagedBy: PackageUpdatingType

    public static func == (lhs: OutdatedPackage, rhs: OutdatedPackage) -> Bool
    {
        return lhs.package.name == rhs.package.name
    }

    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(package.name)
    }
}
