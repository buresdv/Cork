//
//  AppState.swift
//  Cork
//
//  Created by David Bureš on 05.02.2023.
//

import Foundation
import AppKit
import UserNotifications

@MainActor
class AppState: ObservableObject {
    @Published var navigationSelection: UUID?
    
    @Published var notificationEnabledInSystemSettings: Bool?
    @Published var notificationAuthStatus: UNAuthorizationStatus = .notDetermined
    
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
    @Published var offendingTapProhibitingRemovalOfTap: String = ""
    @Published var isShowingRemoveTapFailedAlert: Bool = false
    
    @Published var isShowingIncrementalUpdateSheet: Bool = false
    
    @Published var isLoadingFormulae: Bool = true
    @Published var isLoadingCasks: Bool = true
    
    @Published var isLoadingTopPackages: Bool = false
    
    @Published var cachedDownloadsFolderSize: Int64 = directorySize(url: AppConstants.brewCachedDownloadsPath)
    
    @Published var taggedPackageNames: Set<String> = .init()
    
    @Published var corruptedPackage: String = ""
    
    // MARK: - Notification setup
    func setupNotifications() async
    {
        let notificationCenter = AppConstants.notificationCenter
        
        let authStatus = await notificationCenter.authorizationStatus()

        switch authStatus
        {
            case .notDetermined:
                print("Notification authorization status not determined. Will request notifications again")
                
                await self.requestNotificationAuthorization()
            case .denied:
                print("Notifications were refused")
            case .authorized:
                print("Notifications were authorized")
                
            case .provisional:
                print("Notifications are provisional")
                
            case .ephemeral:
                print("Notifications are ephemeral")
                
            @unknown default:
                print("Something got really fucked up")
        }
        
        notificationAuthStatus = authStatus
    }
    
    func requestNotificationAuthorization() async
    {
        let notificationCenter = AppConstants.notificationCenter
        
        do
        {
            try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            
            notificationEnabledInSystemSettings = true
        }
        catch let notificationPermissionsObtainingError as NSError
        {
            print("Error: \(notificationPermissionsObtainingError.localizedDescription)")
            print("Error code: \(notificationPermissionsObtainingError.code)")
            
            notificationEnabledInSystemSettings = false
        }
    }
    
    // MARK: - Initiating the update process from legacy contexts
    @objc func startUpdateProcessForLegacySelectors(_ sender: NSMenuItem!) -> Void
    {
        self.isShowingUpdateSheet = true
        
        sendNotification(title: String(localized: "notification.upgrade-process-started"))
    }
    
    func setCorruptedPackage(_ name: String) {
        corruptedPackage = name
        fatalAlertType = .installedPackageHasNoVersions
        isShowingFatalError = true 
    }
    
    func setCouldNotParseTopPackages() {
        fatalAlertType = .couldNotParseTopPackages
        isShowingFatalError = true
    }
}

private extension UNUserNotificationCenter {
    func authorizationStatus() async -> UNAuthorizationStatus {
        await notificationSettings().authorizationStatus
    }
}
