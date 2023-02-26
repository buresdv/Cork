//
//  Maintenance View.swift
//  Cork
//
//  Created by David Bureš on 13.02.2023.
//

import SwiftUI

enum RegexError: Error
{
    case foundNilRange
}

enum MaintenanceSteps
{
    case ready, maintenanceRunning, finished
}

struct MaintenanceView: View
{
    @Binding var isShowingSheet: Bool

    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var appState: AppState

    @State var maintenanceSteps: MaintenanceSteps = .ready

    @State var currentMaintenanceStepText: String = "Firing up..."

    @State var shouldPurgeCache: Bool = true
    @State var shouldDeleteDownloads: Bool = true
    @State var shouldUninstallOrphans: Bool = true
    @State var shouldPerformHealthCheck: Bool = false

    @State var numberOfOrphansRemoved: Int = 0

    @State var cachePurgingSkippedPackagesDueToMostRecentVersionsNotBeingInstalled: Bool = false
    @State var packagesHoldingBackCachePurgeTracker: [String] = .init()
    
    @State var brewHealthCheckFoundNoProblems: Bool = false

    @State var maintenanceFoundNoProblems: Bool = true

    @State var reclaimedSpaceAfterCachePurge: Int64 = 0
    
    @State var forcedOptions: Bool? = false
    
    var body: some View
    {
        VStack(alignment: .leading, spacing: 10)
        {
            switch maintenanceSteps
            {
            case .ready:
                SheetWithTitle(title: "Perform Brew maintenance")
                {
                    MaintenanceReadyView(shouldUninstallOrphans: $shouldUninstallOrphans, shouldPurgeCache: $shouldPurgeCache, shouldDeleteDownloads: $shouldDeleteDownloads, shouldPerformHealthCheck: $shouldPerformHealthCheck, isShowingSheet: $isShowingSheet, maintenanceSteps: $maintenanceSteps, isShowingControlButtons: true, forcedOptions: forcedOptions!)
                }
                .padding()

            case .maintenanceRunning:
                ProgressView
                {
                    Text(currentMaintenanceStepText)
                        .onAppear
                        {
                            Task
                            {
                                if shouldUninstallOrphans
                                {
                                    currentMaintenanceStepText = "Uninstalling Orphans..."

                                    do
                                    {
                                        let orphanUninstallationOutput = try await uninstallOrphanedPackages()

                                        print("Orphan removal output: \(orphanUninstallationOutput)")

                                        let numberOfUninstalledOrphansRegex: String = "(?<=Autoremoving ).*?(?= unneeded)"

                                        numberOfOrphansRemoved = Int(try regexMatch(from: orphanUninstallationOutput.standardOutput, regex: numberOfUninstalledOrphansRegex)) ?? 0
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
                                    currentMaintenanceStepText = "Purging Cache..."

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
                                    
                                    currentMaintenanceStepText = "Deleting cached downloads..."
                                    
                                    deleteCachedDownloads()
                                    
                                    /// I have to assign the original value of the appState variable to a different variable, because when it updates at the end of the process, I don't want it to update in the result overview
                                    reclaimedSpaceAfterCachePurge = appState.cachedDownloadsFolderSize
                                }
                                else
                                {
                                    print("Will not delete downloads")
                                }

                                if shouldPerformHealthCheck
                                {
                                    currentMaintenanceStepText = "Running Health Check..."

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

            case .finished:
                ComplexWithIcon(systemName: "checkmark.seal")
                {
                    VStack(alignment: .center)
                    {
                        VStack(alignment: .leading, spacing: 5)
                        {
                            Text("Maintenance finished")
                                .font(.headline)

                            if shouldUninstallOrphans
                            {
                                if numberOfOrphansRemoved == 0
                                {
                                    Text("No orphaned packages found")
                                }
                                else
                                {
                                    Text("\(numberOfOrphansRemoved) orphaned packages removed")
                                }
                            }

                            if shouldPurgeCache
                            {
                                VStack(alignment: .leading)
                                {
                                    Text("Package cache purged")

                                    if cachePurgingSkippedPackagesDueToMostRecentVersionsNotBeingInstalled
                                    {
                                        Text("Some package caches weren't purged because they were held back by \(packagesHoldingBackCachePurgeTracker.joined(separator: ", ")) not being updated")
                                            .font(.caption)
                                            .foregroundColor(Color(nsColor: NSColor.systemGray))
                                    }
                                }
                            }
                            
                            if shouldDeleteDownloads
                            {
                                VStack(alignment: .leading) {
                                    Text("Cached downloads deleted")
                                    Text("You reclaimed \(convertDirectorySizeToPresentableFormat(size: reclaimedSpaceAfterCachePurge))")
                                        .font(.caption)
                                        .foregroundColor(Color(nsColor: NSColor.systemGray))
                                }
                            }

                            if shouldPerformHealthCheck
                            {
                                if brewHealthCheckFoundNoProblems
                                {
                                    Text("No problems with Homebrew found")
                                }
                                else
                                {
                                    Text("There were some problems with Homebrew")
                                        .onAppear
                                        {
                                            maintenanceFoundNoProblems = false
                                        }
                                }
                            }
                        }
                        //.frame(maxWidth: 200)

                        Spacer()

                        HStack
                        {
                            Spacer()

                            Button
                            {
                                isShowingSheet.toggle()
                                
                                appState.cachedDownloadsFolderSize = directorySize(url: AppConstants.brewCachedDownloadsPath)
                            } label: {
                                Text("Close")
                            }
                            .keyboardShortcut(.defaultAction)
                        }
                    }
                    //.fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                //.frame(minWidth: 300, minHeight: 150)
                .onAppear
                {
                    Task
                    {
                        await synchronizeInstalledPackages(brewData: brewData)
                    }
                }
            }
        }
    }
}
