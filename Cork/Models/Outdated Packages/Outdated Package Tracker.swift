//
//  Outdated Package.swift
//  Cork
//
//  Created by David Bureš on 15.03.2023.
//

import Foundation
import SwiftUI

@Observable @MainActor
class OutdatedPackagesTracker
{
    @ObservationIgnored @AppStorage("displayOnlyIntentionallyInstalledPackagesByDefault") var displayOnlyIntentionallyInstalledPackagesByDefault: Bool = true
    
    @ObservationIgnored @AppStorage("includeGreedyOutdatedPackages") var includeGreedyOutdatedPackages: Bool = false

    var outdatedPackages: Set<OutdatedPackage> = .init()
    enum OutdatedPackageDisplayStage: Equatable
    {
        case checkingForUpdates, showingOutdatedPackages, noUpdatesAvailable, erroredOut(reason: String)
    }
    
    var isCheckingForPackageUpdates: Bool = true

    var outdatedPackages: Set<OutdatedPackage> = .init()
    
    var errorOutReason: String?

    var displayableOutdatedPackages: Set<OutdatedPackage>
    {
        /// Depending on whether greedy updating is enabled:
        /// - If enabled, include packages that are also self-updating
        /// - If disabled, include only packages whose updates are managed by Homebrew
        var relevantOutdatedPackages: Set<OutdatedPackage>
        
        if includeGreedyOutdatedPackages
        {
            relevantOutdatedPackages = outdatedPackages
        }
        else
        {
            relevantOutdatedPackages = outdatedPackages.filter{ $0.updatingManagedBy == .homebrew }
        }
        
        if displayOnlyIntentionallyInstalledPackagesByDefault
        {
            return relevantOutdatedPackages.filter(\.package.installedIntentionally)
        }
        else
        {
            return relevantOutdatedPackages
        }
    }
    
    var outdatedPackageDisplayStage: OutdatedPackageDisplayStage
    {
        if let errorOutReason
        {
            return .erroredOut(reason: errorOutReason)
        }
        else
        {
            if isCheckingForPackageUpdates
            {
                return .checkingForUpdates
            }
            else if self.displayableOutdatedPackages.isEmpty
            {
                return .noUpdatesAvailable
            }
            else
            {
                return .showingOutdatedPackages
            }
        }
    }
}

extension OutdatedPackagesTracker
{
    func setOutdatedPackages(to packages: Set<OutdatedPackage>)
    {
        self.outdatedPackages = packages
    }
}

extension OutdatedPackageTracker
{
    func checkForUpdates()
    {
        self.errorOutReason = nil
        self.isCheckingForPackageUpdates = true
    }
}
