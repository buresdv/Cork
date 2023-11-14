//
//  Maintenance Finished View.swift
//  Cork
//
//  Created by David Bureš on 04.10.2023.
//

import SwiftUI

struct MaintenanceFinishedView: View
{
    @AppStorage("displayOnlyIntentionallyInstalledPackagesByDefault") var displayOnlyIntentionallyInstalledPackagesByDefault: Bool = true
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var outdatedPackageTacker: OutdatedPackageTracker

    let shouldUninstallOrphans: Bool
    let shouldPurgeCache: Bool
    let shouldDeleteDownloads: Bool
    let shouldPerformHealthCheck: Bool

    let packagesHoldingBackCachePurge: [String]

    let numberOfOrphansRemoved: Int
    let reclaimedSpaceAfterCachePurge: Int

    let brewHealthCheckFoundNoProblems: Bool

    @Binding var maintenanceFoundNoProblems: Bool
    @Binding var isShowingSheet: Bool

    var body: some View
    {
        ComplexWithIcon(systemName: "checkmark.seal")
        {
            VStack(alignment: .center)
            {
                VStack(alignment: .leading, spacing: 5)
                {
                    Text("maintenance.finished")
                        .font(.headline)

                    if shouldUninstallOrphans
                    {
                        Text("maintenance.results.orphans-count-\(numberOfOrphansRemoved)")
                    }

                    if shouldPurgeCache
                    {
                        VStack(alignment: .leading)
                        {
                            Text("maintenance.results.package-cache")

                            if !packagesHoldingBackCachePurge.isEmpty
                            {
                                if displayOnlyIntentionallyInstalledPackagesByDefault
                                {
                                    /// This abomination of a variable does the following:
                                    /// 1. Filter out only packages that were installed intentionally
                                    /// 2. Get the names of the packages that were installed intentionally
                                    /// 3. Get only the names of packages that were installed intentionally, and are also holding back cache purge
                                    /// **Motivation**: When the user only wants to see packages they have installed intentionally, they will be confused if a dependency suddenly shows up here
                                    //let intentionallyInstalledPackagesHoldingBackCachePurge: [String] = brewData.installedFormulae.filter({ $0.installedIntentionally }).map({ $0.name }).filter{packagesHoldingBackCachePurge.contains($0)}
                                    
                                    /// **Motivation**: Same as above, but more performant
                                    /// Instead of looking through all packages, it only looks through packages that are outdated. Since only outdated packages can hold back purging, it kills two birds with one stone
                                    /// Process:
                                    /// 1. Get only the names of outdated packages
                                    /// 2. Get only the names of packages that are outdated, and are holding back cache purge
                                    //let intentionallyInstalledPackagesHoldingBackCachePurge: [String] = outdatedPackageTacker.outdatedPackages.map(\.package.name).filter({ packagesHoldingBackCachePurge.contains($0) })
                                    
                                    /// **Motivation**: Same as above, but even more performant
                                    /// Only formulae can hold back cache purging. Therefore, we just filter out the outdated formulae, and those must be holding back the purging
                                    let intentionallyInstalledPackagesHoldingBackCachePurge: [String] = outdatedPackageTacker.outdatedPackages.filter({ !$0.package.isCask }).map(\.package.name)
                                    
                                    if !intentionallyInstalledPackagesHoldingBackCachePurge.isEmpty
                                    {
                                        Text("maintenance.results.package-cache.skipped-\(intentionallyInstalledPackagesHoldingBackCachePurge.formatted(.list(type: .and)))")
                                            .font(.caption)
                                            .foregroundColor(Color(nsColor: NSColor.systemGray))
                                    }
                                    
                                }
                                else
                                {
                                    Text("maintenance.results.package-cache.skipped-\(packagesHoldingBackCachePurge.formatted(.list(type: .and)))")
                                        .font(.caption)
                                        .foregroundColor(Color(nsColor: NSColor.systemGray))
                                }
                            }

                            /*
                             if cachePurgingSkippedPackagesDueToMostRecentVersionsNotBeingInstalled
                             {
                             if packagesHoldingBackCachePurgeTracker.count > 2
                             {

                             Text("maintenance.results.package-cache.skipped-\(packagesHoldingBackCachePurgeTracker[0...1].joined(separator: ", "))-and-\(packagesHoldingBackCachePurgeTracker.count - 2)-others")
                             .font(.caption)
                             .foregroundColor(Color(nsColor: NSColor.systemGray))

                             }
                             else
                             {
                             Text("maintenance.results.package-cache.skipped-\(packagesHoldingBackCachePurgeTracker.joined(separator: ", "))")
                             .font(.caption)
                             .foregroundColor(Color(nsColor: NSColor.systemGray))
                             }
                             }
                             */
                        }
                    }

                    if shouldDeleteDownloads
                    {
                        VStack(alignment: .leading)
                        {
                            Text("maintenance.results.cached-downloads")
                            Text("maintenance.results.cached-downloads.summary-\(reclaimedSpaceAfterCachePurge.formatted(.byteCount(style: .file)))")
                                .font(.caption)
                                .foregroundColor(Color(nsColor: NSColor.systemGray))
                        }
                    }

                    if shouldPerformHealthCheck
                    {
                        if brewHealthCheckFoundNoProblems
                        {
                            Text("maintenance.results.health-check.problems-none")
                        }
                        else
                        {
                            Text("maintenance.results.health-check.problems")
                                .onAppear
                                {
                                    maintenanceFoundNoProblems = false
                                }
                        }
                    }
                }

                Spacer()

                HStack
                {
                    Spacer()

                    Button
                    {
                        isShowingSheet.toggle()

                        appState.cachedDownloadsFolderSize = directorySize(url: AppConstants.brewCachedDownloadsPath)
                    } label: {
                        Text("action.close")
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
            .fixedSize()
        }
        .padding()
        // .frame(minWidth: 300, minHeight: 150)
        .onAppear // This should stay this way, I don' want the task to be cancelled when the view disappears
        {
            Task
            {
                await synchronizeInstalledPackages(brewData: brewData)
            }
        }
    }
}
