//
//  Install Package.swift
//  Cork
//
//  Created by David Bureš on 28.04.2026.
//

import CorkShared
import CorkTerminalFunctions
import Foundation

extension InstallationProgressTracker
{
    @MainActor
    public func installPackage(
        _ packageToInstall: MinimalHomebrewPackage,
        using brewPackagesTracker: BrewPackagesTracker,
        cachedDownloadsTracker: CachedDownloadsTracker
    ) async throws(InstallationError)
    {
        AppConstants.shared.logger.debug("Installing package \(packageToInstall.name), privacy: .auto), of type \(packageToInstall.type)")

        do
        {
            switch packageToInstall.type
            {
            case .formula:
                try await installFormula(packageToInstall)
            case .cask:
                try await installCask(packageToInstall)
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
