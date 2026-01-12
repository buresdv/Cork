//
//  Outdated Package.swift
//  Cork
//
//  Created by David Bureš - P on 28.10.2025.
//

import Foundation
import CorkModels

@Observable @MainActor
public final class OutdatedPackage: Identifiable, Equatable, Hashable
{
    public init(
        package: BrewPackage,
        installedVersions: [String],
        newerVersion: String,
        updatingManagedBy: PackageUpdatingType
    ) {
        self.package = package
        self.installedVersions = installedVersions
        self.newerVersion = newerVersion
        self.isMarkedForUpdating = true
        self.updatingManagedBy = updatingManagedBy
    }
    
    public enum PackageUpdatingType: Sendable
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

    public let package: BrewPackage

    public let installedVersions: [String]
    public let newerVersion: String

    public var isMarkedForUpdating: Bool

    public let updatingManagedBy: PackageUpdatingType

    public nonisolated static func == (lhs: OutdatedPackage, rhs: OutdatedPackage) -> Bool
    {
        return lhs.package.name == rhs.package.name
    }

    public nonisolated func hash(into hasher: inout Hasher)
    {
        hasher.combine(package.name)
    }
    
    public func changeMarkedState(to state: Bool? = nil)
    {
        if let state
        {
            self.isMarkedForUpdating = state
        }
        else
        {
            self.isMarkedForUpdating.toggle()
        }
    }
}
