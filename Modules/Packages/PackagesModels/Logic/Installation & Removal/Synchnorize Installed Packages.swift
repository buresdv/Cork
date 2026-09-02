//
//  Synchnorize Installed Packages.swift
//  Cork
//
//  Created by David Bureš on 23.02.2023.
//

import CorkShared
import Foundation
import SwiftUI
import FactoryKit

public extension BrewPackagesTracker
{
    /// Synchronizes installed packages and cached downloads
    nonisolated
    func synchronizeInstalledPackages() async
    {
        guard await !self.isPackageSynchronizationRunning else {
            AppConstants.shared.logger.info("Package synchronization was already in progress - will not start another process")
            return
        }
        
        AppConstants.shared.logger.debug("Will start synchronization process")
        
        async let wasFormulaSynchronizationNeeded: Bool = await synchronizeInstalledFormulaeIfNeeded()
        async let wasCaskSynchronizationNeeded: Bool = await synchronizeInstalledCasksIfNeeded()
        
        await synchronizeAdoptablePackagesIfNeeded(
            wasCaskSynchronizationNeeded: wasCaskSynchronizationNeeded
        )
        
        await cachedDownloadsTracker.loadCachedDownloadedPackages(brewPackagesTracker: self)
    }
    
    @discardableResult
    private func synchronizeInstalledFormulaeIfNeeded() async -> Bool
    {
        let isFormulaReloadNeeded: Bool = await self.checkIfReloadIsNeeded(for: .formula)
        
        AppConstants.shared.logger.info("Is Formula reload needed? \(isFormulaReloadNeeded)")
        
        if isFormulaReloadNeeded
        {
            async let updatedFormulaeTracker: BrewPackages? = await self.loadInstalledPackages(packageTypeToLoad: .formula, appState: AppState())
            
            if let updatedFormulaeTracker = await updatedFormulaeTracker
            {
                withAnimation
                {
                    self.installedFormulae = updatedFormulaeTracker
                }
            }
        }
        
        return isFormulaReloadNeeded
    }
    
    @discardableResult
    private func synchronizeInstalledCasksIfNeeded() async -> Bool
    {
        let isCaskReloadNeeded: Bool = await self.checkIfReloadIsNeeded(for: .cask)
        
        AppConstants.shared.logger.info("Is Cask reload needed? \(isCaskReloadNeeded)")
        
        if isCaskReloadNeeded
        {
            async let updatedCasksTracker: BrewPackages? = await self.loadInstalledPackages(packageTypeToLoad: .cask, appState: AppState())
            
            if let updatedCasksTracker = await updatedCasksTracker
            {
                withAnimation
                {
                    self.installedCasks = updatedCasksTracker
                }
            }
        }
        
        return isCaskReloadNeeded
    }
    
    private func synchronizeAdoptablePackagesIfNeeded(wasCaskSynchronizationNeeded: Bool) async
    {
        if wasCaskSynchronizationNeeded
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
            AppConstants.shared.logger.error("Is Adoptable Packages reload needed? \(wasCaskSynchronizationNeeded)")
        }
    }
}
