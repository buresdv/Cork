//
//  Maintenance Finished View.swift
//  Cork
//
//  Created by David Bureš on 04.10.2023.
//

import CorkShared
import SwiftUI
import Defaults
import CorkModels
import FactoryKit

struct MaintenanceFinishedView: View
{    
    struct MaintenanceResults
    {
        struct CachePurgeResults
        {
            let reclaimedSpace: Int?
            let packagesHoldingBackPurge: [String]?
        }
        
        struct OrphanRemovalResults
        {
            let numberOfOprhansRemoved: Int?
        }
        
        struct HealthCheckResults
        {
            let healthCheckResults: MaintenanceView.HealthCheckStatus
        }
        
        let cachePurgeResults: CachePurgeResults?
        let orphanRemovalResults: OrphanRemovalResults?
        let healthCheckResults: HealthCheckResults?
    }
    
    @Default(.displayOnlyIntentionallyInstalledPackagesByDefault) var displayOnlyIntentionallyInstalledPackagesByDefault: Bool

    @Environment(\.dismiss) var dismiss: DismissAction

    @InjectedObservable(\.appState) var appState: AppState
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker

    @Environment(CachedDownloadsTracker.self) var cachedDownloadsTracker: CachedDownloadsTracker

    @Environment(OutdatedPackagesTracker.self) var outdatedPackagesTracker: OutdatedPackagesTracker

    let maintenanceResults: MaintenanceResults

    var displayablePackagesHoldingBackCachePurge: [String]
    {
        guard let packagesHoldingBackPurge = maintenanceResults.cachePurgeResults?.packagesHoldingBackPurge else
        {
            return .init()
        }
        
        // See if the user wants to see all packages, or just those that are installed manually
        // If they only want to see those installed manually, only show those that are holding back cache purge that are actually only installed manually

        if displayOnlyIntentionallyInstalledPackagesByDefault
        {
            /// This abomination of a variable does the following:
            /// 1. Filter out only packages that were installed intentionally
            /// 2. Get the names of the packages that were installed intentionally
            /// 3. Get only the names of packages that were installed intentionally, and are also holding back cache purge
            /// **Motivation**: When the user only wants to see packages they have installed intentionally, they will be confused if a dependency suddenly shows up here
            // let intentionallyInstalledPackagesHoldingBackCachePurge: [String] = brewPackagesTracker.installedFormulae.filter({ $0.installedIntentionally }).map({ $0.name }).filter{packagesHoldingBackCachePurge.contains($0)}

            /// **Motivation**: Same as above, but more performant
            /// Instead of looking through all packages, it only looks through packages that are outdated. Since only outdated packages can hold back purging, it kills two birds with one stone
            /// Process:
            /// 1. Get only the names of outdated packages
            /// 2. Get only the names of packages that are outdated, and are holding back cache purge
            // let intentionallyInstalledPackagesHoldingBackCachePurge: [String] = outdatedPackageTacker.outdatedPackages.map(\.package.getPackageName(withPrecision: .precise)).filter({ packagesHoldingBackCachePurge.contains($0) })

            /// **Motivation**: Same as above, but even more performant
            /// Only formulae can hold back cache purging. Therefore, we just filter out the outdated formulae, and those must be holding back the purging
            return outdatedPackagesTracker.allDisplayableOutdatedPackages.filter { $0.package.type == .formula }.map{
                $0.package.name(withPrecision: .precise)
            }
        }
        else
        {
            return packagesHoldingBackPurge
        }
    }

    var body: some View
    {
        ComplexWithIcon(systemName: "checkmark.seal")
        {
            VStack(alignment: .leading, spacing: 5)
            {
                
                Text("maintenance.finished")
                    .font(.headline)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                
                if let orphanRemovalResults = maintenanceResults.orphanRemovalResults
                {
                    if let numberOfOrphansRemoved = orphanRemovalResults.numberOfOprhansRemoved
                    {
                        Text("maintenance.results.orphans-count-\(numberOfOrphansRemoved.formatted(.number))")
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                if let cachePurgeResults = maintenanceResults.cachePurgeResults
                {
                    VStack(alignment: .leading)
                    {
                        Text("maintenance.results.package-cache")
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)

                        if !displayablePackagesHoldingBackCachePurge.isEmpty
                        {
                            if displayablePackagesHoldingBackCachePurge.count >= 3
                            {
                                let packageNamesNotTruncated: [String] = Array(displayablePackagesHoldingBackCachePurge.prefix(3))

                                let numberOfTruncatedPackages: Int = displayablePackagesHoldingBackCachePurge.count - packageNamesNotTruncated.count

                                Text("maintenance.results.package-cache.skipped-\(packageNamesNotTruncated.formatted(.list(type: .and)))-and-\(numberOfTruncatedPackages)-others")
                                    .font(.caption)
                                    .foregroundColor(Color(nsColor: NSColor.systemGray))
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            else
                            {
                                Text("maintenance.results.package-cache.skipped-\(displayablePackagesHoldingBackCachePurge.formatted(.list(type: .and)))")
                                    .font(.caption)
                                    .foregroundColor(Color(nsColor: NSColor.systemGray))
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
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
                
                if let reclaimedSpaceAfterCachePurge = maintenanceResults.cachePurgeResults?.reclaimedSpace
                {
                    VStack(alignment: .leading)
                    {
                        Text("maintenance.results.cached-downloads")
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("maintenance.results.cached-downloads.summary-\(reclaimedSpaceAfterCachePurge.formatted(.byteCount(style: .file)))")
                            .font(.caption)
                            .foregroundColor(Color(nsColor: NSColor.systemGray))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                if let healthCheckResults = maintenanceResults.healthCheckResults?.healthCheckResults
                {
                    switch healthCheckResults
                    {
                    case .notRunYet:
                        EmptyView()
                    case .noProblemsFound:
                        Text("maintenance.results.health-check.problems-none")
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    case .problemsFound(let problems):
                        DisclosureGroup
                        {
                            List(problems, id: \.self)
                            { problem in
                                Text(problem)
                            }
                            .listStyle(.bordered)
                            .alternatingRowBackgrounds()
                            .frame(minHeight: 200)
                            .fixedSize(horizontal: false, vertical: true)
                        } label: {
                            Text("maintenance.results.health-check.problems")
                        }
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .task
        {
            do
            {
                try await brewPackagesTracker.synchronizeInstalledPackages(cachedDownloadsTracker: cachedDownloadsTracker)
            }
            catch let synchronizationError
            {
                appState.showAlert(errorToShow: .couldNotSynchronizePackages(error: synchronizationError.localizedDescription))
            }
        }
    }
}
