//
//  AppState.swift
//  Cork
//
//  Created by David Bureš on 05.02.2023.
//

import Foundation

class AppState: ObservableObject {
    /// Stuff for controlling various sheets from the menu bar
    @Published var isShowingInstallationSheet: Bool = false
    @Published var isShowingUninstallationSheet: Bool = false
    @Published var isShowingMaintenanceSheet: Bool = false
    @Published var isShowingTapATapSheet: Bool = false
    @Published var isShowingUpdateSheet: Bool = false
    
    @Published var isShowingUninstallationProgressView: Bool = false
    @Published var isShowingUninstallationNotPossibleDueToDependencyAlert: Bool = false
    @Published var offendingDependencyProhibitingUninstallation: String = ""
    @Published var isShowingUntappingFailedAlert: Bool = false
    
    @Published var isLoadingFormulae: Bool = true
    @Published var isLoadingCasks: Bool = true
    
    @Published var cachedDownloadsFolderSize: String = convertDirectorySizeToPresentableFormat(size: directorySize(url: AppConstants.brewCachePath))
}
