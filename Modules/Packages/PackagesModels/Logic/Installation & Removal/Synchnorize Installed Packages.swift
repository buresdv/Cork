//
//  Synchnorize Installed Packages.swift
//  Cork
//
//  Created by David Bureš on 23.02.2023.
//

import CorkShared
import Foundation
import SwiftUI

public extension BrewPackagesTracker
{
    /// Synchronizes installed packages and cached downloads
    func synchronizeInstalledPackages(
        cachedDownloadsTracker: CachedDownloadsTracker
    ) async throws(PackageSynchronizationError)
    {
        AppConstants.shared.logger.debug("Will start synchronization process")
        
        /// Save the old casks, we will compare them to see if we need to reload adoptable apps later
        let oldLoadedCasks: Set<BrewPackage> = self.successfullyLoadedCasks
        
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
        
        AppConstants.shared.logger.debug("Number of old packages: \(oldLoadedCasks.count), Number of new packages: \(self.successfullyLoadedCasks.count)")
        
        if self.successfullyLoadedCasks.count != oldLoadedCasks.count
        {
            do
            {
                
                self.adoptableApps = try await self.getAdoptableCasks(cacheUsePolicy: .useCachedData)
            } catch let adoptableCasksSynchronizationError {
                AppConstants.shared.logger.error("Failed while synchronizing adoptable casks: \(adoptableCasksSynchronizationError)")
            }
        }
        else
        {
            AppConstants.shared.logger.error("No changes to packages. No need to reload the adoptable apps.")
        }
    }
}
