//
//  AppState.swift
//  Cork
//
//  Created by David Bureš on 05.02.2023.
//

import Foundation
import AppKit

class AppState: ObservableObject {
    @Published var navigationSelection: UUID?
    
    /// Stuff for controlling various sheets from the menu bar
    @Published var isShowingInstallationSheet: Bool = false
    @Published var isShowingPackageReinstallationSheet: Bool = false
    @Published var isShowingUninstallationSheet: Bool = false
    @Published var isShowingMaintenanceSheet: Bool = false
    @Published var isShowingFastCacheDeletionMaintenanceView: Bool = false
    @Published var isShowingAddTapSheet: Bool = false
    @Published var isShowingUpdateSheet: Bool = false
    
    @Published var isCheckingForPackageUpdates: Bool = false
    
    @Published var isShowingUninstallationProgressView: Bool = false
    @Published var isShowingFatalError: Bool = false
    @Published var fatalAlertType: FatalAlertType = .uninstallationNotPossibleDueToDependency
    @Published var offendingDependencyProhibitingUninstallation: String = ""
    @Published var isShowingRemoveTapFailedAlert: Bool = false
    
    @Published var isShowingIncrementalUpdateSheet: Bool = false
    
    @Published var isLoadingFormulae: Bool = true
    @Published var isLoadingCasks: Bool = true
    
    @Published var cachedDownloadsFolderSize: Int64 = directorySize(url: AppConstants.brewCachedDownloadsPath)
    
    @Published var taggedPackageNames: Set<String> = .init()
    
    @Published var corruptedPackage: String = ""
    
    // MARK: - Initiating the update process from legacy contexts
    @objc func startUpdateProcessForLegacySelectors(_ sender: NSMenuItem!) -> Void
    {
        self.isShowingUpdateSheet = true
    }
}
