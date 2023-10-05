//
//  Maintenance Finished View.swift
//  Cork
//
//  Created by David Bureš on 04.10.2023.
//

import SwiftUI

struct MaintenanceFinishedView: View
{
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var brewData: BrewDataStorage

    let shouldUninstallOrphans: Bool
    let shouldPurgeCache: Bool
    let shouldDeleteDownloads: Bool
    let shouldPerformHealthCheck: Bool

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
