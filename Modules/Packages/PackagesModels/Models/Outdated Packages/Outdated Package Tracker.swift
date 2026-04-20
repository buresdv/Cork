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

@MainActor
@Observable
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

    // MARK: - Matchers

    public enum UpdateProcessMatcher: TerminalOutputMatchable
    {
        public enum StandardCases: LocalizedStringKey, CustomStringConvertible, TerminalOutputCase
        {
            case downloading = "update-packages.detail-stage.downloading"
            case pouring = "update-packages.detail-stage.pouring"
            case cleanup = "update-packages.detail-stage.cleanup"
            case backingUp = "update-packages.detail-stage.backing-up"
            case linking = "update-packages.detail-stage.linking"

            public var patterns: [String]
            {
                switch self
                {
                case .downloading:
                    ["Downloading"]
                case .pouring:
                    ["Pouring"]
                case .cleanup:
                    ["cleanup"]
                case .backingUp:
                    ["Backing App"]
                case .linking:
                    ["Moving App", "Linking"]
                }
            }

            public var description: String
            {
                switch self
                {
                case .downloading:
                    return "Downloading"
                case .pouring:
                    return "Pouring"
                case .cleanup:
                    return "Cleanup"
                case .backingUp:
                    return "Backing Up"
                case .linking:
                    return "Linking"
                }
            }
        }

        public typealias ErrorCases = ExpectsNoErrors

        public enum IgnoredCases: TerminalOutputCase
        {
            case tapUpdate
            case noChecksumDefined

            public var patterns: [String]
            {
                switch self
                {
                case .tapUpdate: ["tap"]
                case .noChecksumDefined: ["No checksum defined for"]
                }
            }
        }
    }

    public enum IndividialPackageUpdatingStage: TerminalOutputMatchable
    {
        public enum StandardCases: LocalizedStringKey, CustomStringConvertible, TerminalOutputCase
        {
            case downloading
            case installingUpdate
            case cleaningUp

            public var patterns: [String]
            {
                switch self
                {
                case .downloading:
                    ["Fetching"]
                case .installingUpdate:
                    ["Reinstalling", "Installing", "Pouring"]
                case .cleaningUp:
                    ["cleanup"]
                }
            }

            public var description: String
            {
                switch self
                {
                case .downloading:
                    return String(localized: "update-packages.detail-stage.downloading")
                case .installingUpdate:
                    return String(localized: "update-packages.detail-stage.installing-update")
                case .cleaningUp:
                    return String(localized: "update-packages.detail-stage.cleanup")
                }
            }
        }

        public enum ErrorCases: TerminalOutputCase
        {
            /// Post-install scripts provided by the package failed
            case postInstallStepFailed

            /// Expects password
            case terminalRequired

            public var patterns: [String]
            {
                switch self
                {
                case .postInstallStepFailed:
                    ["post-install step did not complete successfully"]
                case .terminalRequired:
                    ["a terminal is required to read the password"]
                }
            }
        }

        public enum IgnoredCases: TerminalOutputCase
        {
            public var patterns: [String]
            {
                ["Caveats"]
            }
        }
    }
    
    public enum IndividualPackageUpdatingError: LocalizedError
    {
        public enum ImplementedError: LocalizedError
        {
            case postInstallStepFailed(rawOutput: String)
            case terminalRequired
        }
        
        case implemented(failedPackage: OutdatedPackage, error: ImplementedError)
        case unimplemented(failedPackage: OutdatedPackage, rawOutput: String)
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
