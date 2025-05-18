//
//  Synchnorize Installed Packages.swift
//  Cork
//
//  Created by David Bureš on 23.02.2023.
//

import CorkShared
import Foundation
import SwiftUI

extension BrewPackagesTracker
{
    /// Synchronizes installed packages and cached downloads
    func synchronizeInstalledPackages(cachedDownloadsTracker: CachedDownloadsTracker) async throws(PackageSynchronizationError)
    {
        AppConstants.shared.logger.debug("Will start synchronization process")
        
        async let updatedFormulaeTracker: BrewPackages? = await self.loadInstalledPackages(packageTypeToLoad: .formula, appState: AppState())
        async let updatedCasksTracker: BrewPackages? = await self.loadInstalledPackages(packageTypeToLoad: .cask, appState: AppState())
        
        guard let safeUpdatedFormulaeTracker = await updatedFormulaeTracker, let safeUpdatedCasksTracker = await updatedCasksTracker else
        {
            throw .synchronizationReturnedNil
        }
        
        withAnimation
        {
            self.installedFormulae = safeUpdatedFormulaeTracker
            self.installedCasks = safeUpdatedCasksTracker
        }
        
        await cachedDownloadsTracker.loadCachedDownloadedPackages(brewPackagesTracker: self)
    }
}
