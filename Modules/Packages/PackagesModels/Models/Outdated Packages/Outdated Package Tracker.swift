//
//  Outdated Package.swift
//  Cork
//
//  Created by David Bureš on 15.03.2023.
//

import CorkShared
import CorkTerminalFunctions
import Defaults
import DefaultsMacros
import FactoryKit
import Foundation
import SwiftUI

@Observable @MainActor
public class OutdatedPackagesTracker
{
    @Injected(\.appConstants) @ObservationIgnored public var appConstants

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
    }

    @ObservationIgnored
    public var updateProcess: Process?

    public var isCheckingForPackageUpdates: Bool

    public var outdatedPackages: Set<OutdatedPackage>

    public var errorOutReason: String?

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
            else if allDisplayableOutdatedPackages.isEmpty
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
        if !packagesManagedByHomebrew.isEmpty && !packagesThatUpdateThemselves.isEmpty
        { /// Managed packages are not empty, unmanaged packages are not empty
            return .bothManagedAndUnmanaged
        }
        else if packagesManagedByHomebrew.isEmpty && !packagesThatUpdateThemselves.isEmpty
        { /// Managed packages are empty, unmanaged packages are not empty
            return .unmanagedOnly
        }
        else
        {
            return .managedOnly
        }
    }
    
    public func insertDebugElementIntoOutdatedPackagesTracker() -> Void
    {
        appConstants.logger.debug("Will attempt to put debug element into the outdated packages tracker")
        
        self.outdatedPackages.insert(.init(package: .init(rawName: "debug@\(Int.random(in: 1...100000))", type: .cask, installedOn: .now, versions: [], url: nil, sizeInBytes: nil, downloadCount: nil), installedVersions: [], newerVersion: String(Int.random(in: 1...200)), updatingManagedBy: .homebrew))
        
        appConstants.logger.debug("Number of packages in tracker: \(self.outdatedPackages.count)")
    }
}

public extension OutdatedPackagesTracker
{
    var allDisplayableOutdatedPackages: Set<OutdatedPackage>
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

    var packagesMarkedForUpdating: [OutdatedPackage]
    {
        return allDisplayableOutdatedPackages.filter { $0.isSelected }
    }

    var packagesManagedByHomebrew: Set<OutdatedPackage>
    {
        return allDisplayableOutdatedPackages.filter { $0.updatingManagedBy == .homebrew }
    }

    var packagesThatUpdateThemselves: Set<OutdatedPackage>
    {
        return allDisplayableOutdatedPackages.filter { $0.updatingManagedBy == .selfUpdating }
    }

    var areAllOutdatedPackagesMarkedForUpdating: Bool
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

public extension OutdatedPackagesTracker
{
    // Set all outdated packages to this selected state
    func setAllPackagesToSelectedState(stateToSet: Bool)
    {
        for outdatedPackage in self.outdatedPackages
        {
            outdatedPackage.changeSelectedState(to: stateToSet)
        }
    }
    
    func setOnlyOnePackageToSelectedState(
        packageToSingleOut: OutdatedPackage,
        selectedStateToSetThatOnePackageTo: Bool
    ) {
        self.outdatedPackages.forEach
        { outdatedPackage in
            if outdatedPackage == packageToSingleOut
            {
                outdatedPackage.changeSelectedState(to: selectedStateToSetThatOnePackageTo)
            }
            else
            {
                outdatedPackage.changeSelectedState(to: !selectedStateToSetThatOnePackageTo)
            }
        }
    }
}
