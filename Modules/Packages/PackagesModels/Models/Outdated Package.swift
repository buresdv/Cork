//
//  Outdated Package.swift
//  Cork
//
//  Created by David Bureš - P on 28.10.2025.
//

import Foundation

public struct OutdatedPackage: Identifiable, Equatable, Hashable
{
    public init(package: BrewPackage, installedVersions: [String], newerVersion: String, updatingManagedBy: PackageUpdatingType) {
        self.package = package
        self.installedVersions = installedVersions
        self.newerVersion = newerVersion
        self.isMarkedForUpdating = true
        self.updatingManagedBy = updatingManagedBy
    }
    
    public enum PackageUpdatingType
    {
        /// The package is updating through Homebrew
        case homebrew

        /// The package updates itself
        case selfUpdating

        public var argument: String
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

    public let package: BrewPackage

    public let installedVersions: [String]
    public let newerVersion: String

    public var isMarkedForUpdating: Bool

    public var updatingManagedBy: PackageUpdatingType

    public static func == (lhs: OutdatedPackage, rhs: OutdatedPackage) -> Bool
    {
        return lhs.package.name == rhs.package.name
    }

    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(package.name)
    }
}
