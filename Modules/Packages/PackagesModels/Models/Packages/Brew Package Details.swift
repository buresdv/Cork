//
//  Brew Package details.swift
//  CorkModels
//
//  Created by David Bureš - P on 10.11.2025.
//

import Foundation
import CorkShared
import CorkTerminalFunctions

enum PinningUnpinningError: LocalizedError
{
    case failedWhileChangingPinnedStatus

    var errorDescription: String?
    {
        switch self
        {
        case .failedWhileChangingPinnedStatus:
            return String(localized: "error.package-details.couldnt-pin-unpin")
        }
    }
}

public extension BrewPackage
{
    /// MOre information about this Homebrew package
    @Observable @MainActor
    class BrewPackageDetails
    {
        // MARK: - Immutable properties

        /// Name of the package
        public let name: String

        public let description: String?

        public let homepage: URL
        public let tap: BrewTap
        public let installedAsDependency: Bool
        public let dependencies: [BrewPackageDependency]?
        public let outdated: Bool
        public let caveats: String?
        
        public let deprecated: Bool
        public let deprecationReason: String?

        public let isCompatible: Bool?

        public var dependents: [String]?

        // MARK: - Init

        public init(
            name: String,
            description: String?,
            homepage: URL,
            tap: BrewTap,
            installedAsDependency: Bool,
            dependents: [String]? = nil,
            dependencies: [BrewPackageDependency]? = nil,
            outdated: Bool,
            caveats: String? = nil,
            deprecated: Bool,
            deprecationReason: String? = nil,
            isCompatible: Bool?
        ){
            self.name = name
            self.description = description
            self.homepage = homepage
            self.tap = tap
            self.installedAsDependency = installedAsDependency
            self.dependents = dependents
            self.dependencies = dependencies
            self.outdated = outdated
            self.deprecated = deprecated
            self.deprecationReason = deprecationReason
            self.caveats = caveats
            self.isCompatible = isCompatible
        }

        // MARK: - Functions

        public func loadDependents() async
        {
            AppConstants.shared.logger.debug("Will load dependents for \(self.name)")
            let packageDependentsRaw: String = await shell(AppConstants.shared.brewExecutablePath, ["uses", "--installed", name]).standardOutput

            let finalDependents: [String] = packageDependentsRaw.components(separatedBy: "\n").dropLast()

            AppConstants.shared.logger.debug("Dependents loaded: \(finalDependents)")

            dependents = finalDependents
        }
    }
}
