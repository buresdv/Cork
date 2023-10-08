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
                            print(orphanUninstallatioError)
                        }
                    }
                    else
                    {
                        print("Will not uninstall orphans")
                    }

                    if shouldPurgeCache
                    {
                        currentMaintenanceStepText = "maintenance.step.purging-cache"

                        do
                        {
                            packagesHoldingBackCachePurge = try await purgeHomebrewCacheUtility()

                            print("Length of array of packages that are holding back cache purge: \(packagesHoldingBackCachePurge.count)")
                        }
                        catch let homebrewCachePurgingError
                        {
                            print("Homebrew cache purging failed: \(homebrewCachePurgingError)")
                        }
                    }
                    else
                    {
                        print("Will not purge cache")
                    }

                    if shouldDeleteDownloads
                    {
                        print("Will delete downloads")

                        currentMaintenanceStepText = "maintenance.step.deleting-cached-downloads"

                        deleteCachedDownloads()

                        /// I have to assign the original value of the appState variable to a different variable, because when it updates at the end of the process, I don't want it to update in the result overview
                        reclaimedSpaceAfterCachePurge = Int(appState.cachedDownloadsFolderSize)
                    }
                    else
                    {
                        print("Will not delete downloads")
                    }

                    if shouldPerformHealthCheck
                    {
                        currentMaintenanceStepText = "maintenance.step.running-health-check"

                        do
                        {
                            let healthCheckOutput = try await performBrewHealthCheck()
                            print("Health check output: \(healthCheckOutput)")

                            brewHealthCheckFoundNoProblems = true
                        }
                        catch let healthCheckError as NSError
                        {
                            print(healthCheckError)
                        }
                    }
                    else
                    {
                        print("Will not perform health check")
                    }

                    maintenanceSteps = .finished
                }
        }
        .padding()
        .frame(width: 200)
    }
}
