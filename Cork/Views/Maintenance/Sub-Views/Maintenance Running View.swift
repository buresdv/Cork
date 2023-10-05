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
    @Binding var packagesHoldingBackCachePurgeTracker: [String]
    @Binding var cachePurgingSkippedPackagesDueToMostRecentVersionsNotBeingInstalled: Bool
    @Binding var reclaimedSpaceAfterCachePurge: Int
    @Binding var brewHealthCheckFoundNoProblems: Bool
    @Binding var maintenanceSteps: MaintenanceSteps

    var body: some View
    {
        ProgressView
        {
            Text(currentMaintenanceStepText)
                .onAppear
                {
                    Task
                    {
                        if shouldUninstallOrphans
                        {
                            currentMaintenanceStepText = "maintenance.step.removing-orphans"

                            do
                            {
                                let orphanUninstallationOutput = try await uninstallOrphanedPackages()

                                print("Orphan removal output: \(orphanUninstallationOutput)")

                                let numberOfUninstalledOrphansRegex: String = "(?<=Autoremoving ).*?(?= unneeded)"

                                numberOfOrphansRemoved = try Int(regexMatch(from: orphanUninstallationOutput.standardOutput, regex: numberOfUninstalledOrphansRegex)) ?? 0
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

                            let cachePurgeOutput = try await purgeBrewCache()
                            print("Cache purge output: \(cachePurgeOutput)")

                            if cachePurgeOutput.standardError.contains("Warning: Skipping")
                            { // Here, we'll write out all the packages that are blocking updating
                                var packagesHoldingBackCachePurgeInitialArray = cachePurgeOutput.standardError.components(separatedBy: "Warning:") // The output has these packages in one giant list. Split them into an array so we can iterate over them and extract their names
                                // I can't just try to regex-match on the raw output, because it will only match the first package in that case

                                packagesHoldingBackCachePurgeInitialArray.removeFirst() // The first element in this array is "" for some reason, remove that so we save some resources

                                for blockingPackageRaw in packagesHoldingBackCachePurgeInitialArray
                                {
                                    print("Blocking package: \(blockingPackageRaw)")

                                    let packageHoldingBackCachePurgeNameRegex = "(?<=Skipping ).*?(?=:)"

                                    let packageHoldingBackCachePurgeName = try regexMatch(from: blockingPackageRaw, regex: packageHoldingBackCachePurgeNameRegex)

                                    packagesHoldingBackCachePurgeTracker.append(packageHoldingBackCachePurgeName)
                                }

                                print("These packages are holding back cache purge: \(packagesHoldingBackCachePurgeTracker)")

                                cachePurgingSkippedPackagesDueToMostRecentVersionsNotBeingInstalled = true
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
        }
        .padding()
        .frame(width: 200)
    }
}
