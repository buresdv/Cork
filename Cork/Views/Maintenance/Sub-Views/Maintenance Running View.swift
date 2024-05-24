//
//  Maintenance Running View.swift
//  Cork
//
//  Created by David Bureš on 04.10.2023.
//

import SwiftUI

struct MaintenanceRunningView: View
{
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var brewData: BrewDataStorage

    @State var currentMaintenanceStepText: LocalizedStringKey = "maintenance.step.initial"

    let shouldUninstallOrphans: Bool
    let shouldPurgeCache: Bool
    let shouldDeleteDownloads: Bool
    let shouldPerformHealthCheck: Bool

    @Binding var numberOfOrphansRemoved: Int
    @Binding var packagesHoldingBackCachePurge: [String]
    @Binding var reclaimedSpaceAfterCachePurge: Int
    @Binding var brewHealthCheckFoundNoProblems: Bool
    @Binding var maintenanceSteps: MaintenanceSteps

    var body: some View
    {
        ProgressView
        {
            Text(currentMaintenanceStepText)
                .task(priority: .userInitiated)
                {
                    if shouldUninstallOrphans
                    {
                        currentMaintenanceStepText = "maintenance.step.removing-orphans"

                        do
                        {
                            numberOfOrphansRemoved = try await uninstallOrphansUtility()
                        }
                        catch let orphanUninstallatioError as NSError
                        {
                            AppConstants.logger.error("Orphan uninstallation error: \(String(describing: orphanUninstallatioError))")
                        }
                    }
                    else
                    {
                        AppConstants.logger.info("Will not uninstall orphans")
                    }

                    if shouldPurgeCache
                    {
                        currentMaintenanceStepText = "maintenance.step.purging-cache"

                        do
                        {
                            packagesHoldingBackCachePurge = try await purgeHomebrewCacheUtility()

                            AppConstants.logger.info("Length of array of packages that are holding back cache purge: \(packagesHoldingBackCachePurge.count)")
                        }
                        catch let homebrewCachePurgingError
                        {
                            AppConstants.logger.error("Homebrew cache purging error: \(String(describing: homebrewCachePurgingError))")
                        }
                    }
                    else
                    {
                        AppConstants.logger.info("Will not purge cache")
                    }

                    if shouldDeleteDownloads
                    {
                        AppConstants.logger.info("Will delete downloads")

                        currentMaintenanceStepText = "maintenance.step.deleting-cached-downloads"

                        deleteCachedDownloads()

                        /// I have to assign the original value of the appState variable to a different variable, because when it updates at the end of the process, I don't want it to update in the result overview
                        reclaimedSpaceAfterCachePurge = Int(appState.cachedDownloadsFolderSize)
                        
                        await appState.loadCachedDownloadedPackages()
                        appState.assignPackageTypeToCachedDownloads(brewData: brewData)
                    }
                    else
                    {
                        AppConstants.logger.info("Will not delete downloads")
                    }

                    if shouldPerformHealthCheck
                    {
                        currentMaintenanceStepText = "maintenance.step.running-health-check"

                        do
                        {
                            let healthCheckOutput = try await performBrewHealthCheck()
                            AppConstants.logger.debug("Health check output:\nStandard output: \(healthCheckOutput.standardOutput)\nStandard error: \(healthCheckOutput.standardError)")

                            brewHealthCheckFoundNoProblems = true
                        }
                        catch let healthCheckError as NSError
                        {
                            AppConstants.logger.error("\(String(describing: healthCheckError))")
                        }
                    }
                    else
                    {
                        AppConstants.logger.info("Will not perform health check")
                    }

                    maintenanceSteps = .finished
                }
        }
        .padding()
        .frame(width: 200)
    }
}
