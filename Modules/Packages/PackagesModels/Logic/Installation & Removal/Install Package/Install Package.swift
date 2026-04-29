//
//  Install Package.swift
//  Cork
//
//  Created by David Bureš on 28.04.2026.
//

import CorkModels
import CorkShared
import CorkTerminalFunctions
import Foundation

extension InstallationProgressTracker
{
    @MainActor
    func installPackage(
        using brewPackagesTracker: BrewPackagesTracker,
        cachedDownloadsTracker: CachedDownloadsTracker
    ) async throws(InstallationError) -> [TerminalOutput]
    {
        let package: BrewPackage = packageBeingInstalled.package

        AppConstants.shared.logger.debug("Installing package \(package.name(withPrecision: .precise), privacy: .auto), of type \(package.type)")

        do
        {
            switch package.type
            {
            case .formula:
                try await installFormula(using: brewPackagesTracker)
            case .cask:
                try await installCask(using: brewPackagesTracker)
            }
        }
        catch let unexpectedError
        {}

        do
        {
            try await brewPackagesTracker.synchronizeInstalledPackages(cachedDownloadsTracker: cachedDownloadsTracker)
        }
        catch let synchronizationError
        {
            throw .implemented(
                .couldNotSynchronizePackages(synchronizationError)
            )
        }

    }
}
