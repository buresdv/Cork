//
//  Brew Package Details.swift
//  Cork
//
//  Created by David Bureš on 18.07.2024.
//

import Foundation
import CorkShared

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

@MainActor
class BrewPackageDetails: ObservableObject
{
    // MARK: - Immutable properties

    /// Name of the package
    let name: String

    let description: String?

    let homepage: URL
    let tap: BrewTap
    let installedAsDependency: Bool
    let dependencies: [BrewPackageDependency]?
    let outdated: Bool
    let caveats: String?
    
    let deprecated: Bool
    let deprecationReason: String?

    let isCompatible: Bool?

    // MARK: - Mutable properties

    @Published var dependents: [String]?
    @Published var pinned: Bool

    // MARK: - Init

    init(name: String, description: String?, homepage: URL, tap: BrewTap, installedAsDependency: Bool, dependents: [String]? = nil, dependencies: [BrewPackageDependency]? = nil, outdated: Bool, caveats: String? = nil, deprecated: Bool, deprecationReason: String? = nil, pinned: Bool, isCompatible: Bool?)
    {
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
        self.pinned = pinned
        self.isCompatible = isCompatible
    }

    // MARK: - Functions

    func loadDependents() async
    {
        AppConstants.shared.logger.debug("Will load dependents for \(self.name)")
        let packageDependentsRaw: String = await shell(AppConstants.shared.brewExecutablePath, ["uses", "--installed", name]).standardOutput

        let finalDependents: [String] = packageDependentsRaw.components(separatedBy: "\n").dropLast()

        AppConstants.shared.logger.debug("Dependents loaded: \(finalDependents)")

        dependents = finalDependents
    }

    func changePinnedStatus() async throws
    {
        if pinned
        {
            let pinResult: TerminalOutput = await shell(AppConstants.shared.brewExecutablePath, ["unpin", name])

            if !pinResult.standardError.isEmpty
            {
                AppConstants.shared.logger.error("Error pinning: \(pinResult.standardError, privacy: .public)")
                throw PinningUnpinningError.failedWhileChangingPinnedStatus
            }
        }
        else
        {
            let unpinResult: TerminalOutput = await shell(AppConstants.shared.brewExecutablePath, ["pin", name])
            if !unpinResult.standardError.isEmpty
            {
                AppConstants.shared.logger.error("Error unpinning: \(unpinResult.standardError, privacy: .public)")
                throw PinningUnpinningError.failedWhileChangingPinnedStatus
            }
        }

        pinned.toggle()
    }
}
