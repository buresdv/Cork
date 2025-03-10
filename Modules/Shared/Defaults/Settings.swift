//
//  Settings.swift
//  CorkShared
//
//  Created by David Bureš - P on 10.03.2025.
//

import Foundation
import Defaults

public extension Defaults.Keys
{
    /// Sorting type of the installed packages in the sidebar
    static let sortPackagesBy: Key<PackageSortingOptions> = .init("sortPackagesBy", default: .byInstallDate)
    
    /// Whether to allow anonymous Homebrew analytics
    static let allowBrewAnalytics: Key<Bool> = .init("allowBrewAnalytics", default: true)
    
    /// Whether to allow purging
    static let allowMoreCompleteUninstallations: Key<Bool> = .init("allowMoreCompleteUninstallations", default: false)
    
    /// Whether to show live Terminal outputs of varous operations
    static let showRealTimeTerminalOutputOfOperations: Key<Bool> = .init("showRealTimeTerminalOutputOfOperations", default: false)
    
    /// Whether to show more info about a package's dependencies, including its version, and if it is a direct dependency
    static let displayAdvancedDependencies: Key<Bool> = .init("displayAdvancedDependencies", default: false)
    
    /// Whether to show a package's caveats as a pill, or as a full, separate section
    static let caveatDisplayOptions: Key<PackageCaveatDisplay> = .init("caveatDisplayOptions", default: .full)
    
    /// Whether descriptions of packages will be shown in the installer sheet
    static let showDescriptionsInSearchResults: Key<Bool> = .init("showDescriptionsInSearchResults", default: false)
    
    /// Whether the info setion about a package's dependencies shows a search field, which allows the searching for dependencies
    static let showSearchFieldForDependenciesInPackageDetails: Key<Bool> = .init("showSearchFieldForDependenciesInPackageDetails", default: false)
    
    /// Sorting type of top packages in the package installed
    static let sortTopPackagesBy: Key<TopPackageSorting> = .init("sortTopPackagesBy", default: .mostDownloads)
    
    /// Whether Cork's menu bar item is shown
    static let showInMenuBar: Key<Bool> = .init("showInMenuBar", default: false)
    
    // MARK: - Package Installation
    /// Whether to warn about packages incompatible with the user's system
    static let showCompatibilityWarning: Key<Bool> = .init("showCompatibilityWarning", default: true)
    
    // MARK: - Notifications
    /// Whether notifications are enabled
    static let areNotificationsEnabled: Key<Bool> = .init("areNotificationsEnabled", default: true)
    
    /// Type of notifications for outdated packages
    /// Types:
    /// - ``OutdatedPackageNotificationType.badge``: Only a badge in the app's icon
    /// - ``OutdatedPackageNotificationType.both``: Badge, as well as a notification
    static let outdatedPackageNotificationType: Key<OutdatedPackageNotificationType> = .init("outdatedPackageNotificationType", default: .badge)
    
    /// Whether to send a notification about the results of a package updating action
    static let notifyAboutPackageUpgradeResults: Key<Bool> = .init("notifyAboutPackageUpgradeResults", default: false)
    
    /// Whether no send a notification about the results of a package installation action
    static let notifyAboutPackageInstallationResults: Key<Bool> = .init("notifyAboutPackageInstallationResults", default: false)
    
    // MARK: - Discoverability
    /// Whether to enable top packages
    static let enableDiscoverability: Key<Bool> = .init("enableDiscoverability", default: false)
}
