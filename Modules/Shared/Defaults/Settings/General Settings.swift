//
//  General Settings.swift
//  Cork
//
//  Created by David Bureš - P on 14.05.2025.
//

import Foundation
import Defaults

public extension Defaults.Keys
{
    // MARK: - Package Sorting
    /// Sorting type of the installed packages in the sidebar
    static let sortPackagesBy: Key<PackageSortingOptions> = .init("sortPackagesBy", default: .byInstallDate)
    
    // MARK: - Package filtering
    /// Whether to show only packages that the user installed manually
    static let displayOnlyIntentionallyInstalledPackagesByDefault: Key<Bool> = .init("displayOnlyIntentionallyInstalledPackagesByDefault", default: true)
    
    // MARK: - Dependencies
    /// Whether to show more info about a package's dependencies, including its version, and if it is a direct dependency
    static let displayAdvancedDependencies: Key<Bool> = .init("displayAdvancedDependencies", default: false)
    
    // MARK: - Package caveats
    /// Whether to show a package's caveats as a pill, or as a full, separate section
    static let caveatDisplayOptions: Key<PackageCaveatDisplay> = .init("caveatDisplayOptions", default: .full)
    
    // MARK: - Search results
    /// Whether descriptions of packages will be shown in the installer sheet
    static let showDescriptionsInSearchResults: Key<Bool> = .init("showDescriptionsInSearchResults", default: false)
    
    // MARK: - Outdated package info
    /// How much information should be shown about outdated packages
    static let outdatedPackageInfoDisplayAmount: Key<OutdatedPackageInfoAmount> = .init("outdatedPackageInfoDisplayAmount", default: .versionOnly)
    
    /// Whether old version numbers should be shown in the outdated package list
    static let showOldVersionsInOutdatedPackageList: Key<Bool> = .init("showOldVersionsInOutdatedPackageList", default: true)
    
    // MARK: - Package details
    /// Whether the info setion about a package's dependencies shows a search field, which allows the searching for dependencies
    static let showSearchFieldForDependenciesInPackageDetails: Key<Bool> = .init("showSearchFieldForDependenciesInPackageDetails", default: false)
    
    /// Whether "Reveal in Finder" is available for various packages
    static let enableRevealInFinder: Key<Bool> = .init("enableRevealInFinder", default: false)
    
    /// Whether swipe actions in the sidebar are enabled
    static let enableSwipeActions: Key<Bool> = .init("enableSwipeActions", default: false)
    
    /// Whether extra UI animations are enabled
    static let enableExtraAnimations: Key<Bool> = .init("enableExtraAnimations", default: true)
 
    // MARK: - Menu bar
    /// Whether Cork's menu bar item is shown
    static let showInMenuBar: Key<Bool> = .init("showInMenuBar", default: false)
    
    /// Whether the app should start without its window
    /// Not implemented at the moment
    static let startWithoutWindow: Key<Bool> = .init("startWithoutWindow", default: false)
}
