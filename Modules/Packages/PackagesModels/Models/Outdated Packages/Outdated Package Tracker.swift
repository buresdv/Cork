//
//  Outdated Package.swift
//  Cork
//
//  Created by David Bureš on 15.03.2023.
//

import Defaults
import DefaultsMacros
import Foundation
import SwiftUI

@MainActor
@Observable
public class OutdatedPackagesTracker
{
    @ObservableDefault(.displayOnlyIntentionallyInstalledPackagesByDefault) @ObservationIgnored var displayOnlyIntentionallyInstalledPackagesByDefault: Bool

    @ObservableDefault(.includeGreedyOutdatedPackages) @ObservationIgnored var includeGreedyOutdatedPackages: Bool

    public enum OutdatedPackageDisplayStage: Equatable
    {
        case checkingForUpdates, showingOutdatedPackages, noUpdatesAvailable, erroredOut(reason: String)
    }

    public init()
    {
        self.isCheckingForPackageUpdates = true
        self.outdatedPackages = .init()
        self.displayableOutdatedPackagesTracker = .init()
    }

    public var isCheckingForPackageUpdates: Bool

    public var outdatedPackages: Set<OutdatedPackage>

    public var errorOutReason: String?

    public var displayableOutdatedPackagesTracker: DisplayableOutdatedPackagesTracker

    public var outdatedPackageDisplayStage: OutdatedPackageDisplayStage
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
            else if displayableOutdatedPackagesTracker.allDisplayableOutdatedPackages.isEmpty
            {
                return .noUpdatesAvailable
            }
            else
            {
                return .showingOutdatedPackages
            }
        }
    }

    /// How to show the outdated packages list, depending on what type out outdated packages are available
    public enum OutdatedPackageListBoxViewType: LocalizedStringKey
    {
        /// Only packages that are managed by Homerbew are outdated
        case managedOnly

        /// Both packages that are managed by Homebrew, and those that are not (available only through the `--greedy` flag) are available
        case bothManagedAndUnmanaged

        /// Only unmanaged packages (available only through the `--greedy` flag) are availabe
        case unmanagedOnly
    }

    public var outdatedPackageListBoxViewType: OutdatedPackageListBoxViewType
    {
        if !displayableOutdatedPackagesTracker.packagesManagedByHomebrew.isEmpty && !displayableOutdatedPackagesTracker.packagesThatUpdateThemselves.isEmpty
        { /// Managed packages are not empty, unmanaged packages are not empty
            return .bothManagedAndUnmanaged
        }
        else if displayableOutdatedPackagesTracker.packagesManagedByHomebrew.isEmpty && !displayableOutdatedPackagesTracker.packagesThatUpdateThemselves.isEmpty
        { /// Managed packages are empty, unmanaged packages are not empty
            return .unmanagedOnly
        }
        else
        {
            return .managedOnly
        }
    }
}

@MainActor
@Observable
public class DisplayableOutdatedPackagesTracker: OutdatedPackagesTracker
{
    public var allDisplayableOutdatedPackages: Set<OutdatedPackage>
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
            relevantOutdatedPackages = outdatedPackages.filter { $0.updatingManagedBy == .homebrew }
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

    public var packagesMarkedForUpdating: [OutdatedPackage]
    {
        return allDisplayableOutdatedPackages.filter { $0.isMarkedForUpdating }
    }

    public var packagesManagedByHomebrew: Set<OutdatedPackage>
    {
        return allDisplayableOutdatedPackages.filter { $0.updatingManagedBy == .homebrew }
    }

    public var packagesThatUpdateThemselves: Set<OutdatedPackage>
    {
        return allDisplayableOutdatedPackages.filter { $0.updatingManagedBy == .selfUpdating }
    }
    
    public var areAllOutdatedPackagesMarkedForUpdating: Bool
    {
        return packagesMarkedForUpdating.count == allDisplayableOutdatedPackages.count
    }
}

public extension OutdatedPackagesTracker
{
    func setOutdatedPackages(to packages: Set<OutdatedPackage>)
    {
        self.outdatedPackages = packages
    }

    func checkForUpdates()
    {
        self.errorOutReason = nil
        self.isCheckingForPackageUpdates = true
    }
}
