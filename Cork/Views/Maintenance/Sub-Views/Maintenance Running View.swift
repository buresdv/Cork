//
//  Maintenance Running View.swift
//  Cork
//
//  Created by David Bureš on 04.10.2023.
//

import SwiftUI
import CorkShared
import CorkModels
import CorkTerminalFunctions
import FactoryKit

struct MaintenanceRunningView: View
{
    @InjectedObservable(\.appState) var appState: AppState
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker

    @Environment(CachedDownloadsTracker.self) var cachedDownloadsTracker: CachedDownloadsTracker
    
    @State var currentMaintenanceStepText: LocalizedStringKey = "maintenance.step.initial"
    
    @Binding var maintenanceSteps: MaintenanceView.MaintenanceStage

    let selectedMaintenanceStepsTracker: MaintenanceView.SelectedMaintenanceStepsTracker
    
    @State private var cachePurgeResults: MaintenanceResults.CachePurgeResults?
    @State private var orphanRemovalResults: MaintenanceResults.OrphanRemovalResults?
    @State private var healthCheckResuts: MaintenanceResults.HealthCheckResults?

    var body: some View
    {
        ProgressView
        {
            Text(currentMaintenanceStepText)
                .task
                {
                    await performMaintenance()
                }
        }
    }
    
    func performMaintenance() async
    {
        if selectedMaintenanceStepsTracker.shouldUninstallOrphans
        {
            currentMaintenanceStepText = "maintenance.step.removing-orphans"

            do
            {
                orphanRemovalResults = .init(numberOfOprhansRemoved: try? await uninstallOrphansUtility())
            }
            catch let orphanUninstallatioError
            {
                AppConstants.shared.logger.error("Orphan uninstallation error: \(orphanUninstallatioError.localizedDescription, privacy: .public))")
            }
        }
        else
        {
            AppConstants.shared.logger.info("Will not uninstall orphans")
        }

        if selectedMaintenanceStepsTracker.shouldPurgeCache
        {
            currentMaintenanceStepText = "maintenance.step.purging-cache"

            do
            {
                let cacheSizeBeforePurge = cachedDownloadsTracker.cachedDownloadsSize
                
                let packagesHoldingBackPurge: [String]? = try? await purgeHomebrewCacheUtility()
                
                let cacheSizeAfterPurge = cachedDownloadsTracker.cachedDownloadsSize
                
                let reclaimedSpaceAfterPurge: Int = cacheSizeBeforePurge - cacheSizeAfterPurge
                
                cachePurgeResults = .init(
                    reclaimedSpace: reclaimedSpaceAfterPurge,
                    packagesHoldingBackPurge: packagesHoldingBackPurge
                )
            }
            catch let homebrewCachePurgingError
            {
                AppConstants.shared.logger.error("Homebrew cache purging error: \(homebrewCachePurgingError.localizedDescription, privacy: .public))")
            }
        }
        else
        {
            AppConstants.shared.logger.info("Will not purge cache")
        }

        if selectedMaintenanceStepsTracker.shouldDeleteDownloads
        {
            AppConstants.shared.logger.info("Will delete downloads")

            currentMaintenanceStepText = "maintenance.step.deleting-cached-downloads"

            do throws(CachedDownloadDeletionError)
            {
                try deleteCachedDownloads()
            }
            catch let cacheDeletionError
            {
                switch cacheDeletionError
                {
                case .couldNotReadContentsOfCachedFormulaeDownloadsFolder(let associatedError):
                    appState.showAlert(errorToShow: .couldNotDeleteCachedDownloads(error: associatedError))
                    
                case .couldNotReadContentsOfCachedCasksDownloadsFolder(let associatedError):
                    appState.showAlert(errorToShow: .couldNotDeleteCachedDownloads(error: associatedError))
                    
                case .couldNotReadContentsOfCachedDownloadsFolder(let associatedError):
                    appState.showAlert(errorToShow: .couldNotDeleteCachedDownloads(error: associatedError))
                }
            }

        }
        else
        {
            AppConstants.shared.logger.info("Will not delete downloads")
        }

        if selectedMaintenanceStepsTracker.shouldPerformHealthCheck
        {
            currentMaintenanceStepText = "maintenance.step.running-health-check"

            do
            {
                try await performBrewHealthCheck()
            }
            catch let healthCheckError
            {
                AppConstants.shared.logger.error("Health check error: \(healthCheckError, privacy: .public)")
                
                switch healthCheckError
                {
                case .errorsThrownInStandardOutput(let errors):
                    healthCheckResuts = .init(healthCheckResults: .problemsFound(problems: errors))
                }
            }
        }
        else
        {
            AppConstants.shared.logger.info("Will not perform health check")
        }

        let maintenanceResults: MaintenanceResults = .init(
            cachePurgeResults: cachePurgeResults,
            orphanRemovalResults: orphanRemovalResults,
            healthCheckResults: healthCheckResuts
        )
        
        maintenanceSteps = .finished(results: maintenanceResults)
    }
}
