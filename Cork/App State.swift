//
//  AppState.swift
//  Cork
//
//  Created by David Bureš on 05.02.2023.
//

import Foundation
import AppKit
import UserNotifications

class AppState: ObservableObject {
    @Published var navigationSelection: UUID?
    
    @Published var notificationEnabledInSystemSettings: Bool?
    @Published var notificationStatus: UNNotificationSettings?
    
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
    @discardableResult
    func setupNotifications() async -> UNNotificationSettings
    {
        let notificationCenter = AppConstants.notificationCenter
        
        let notificationSettingsStatus = await notificationCenter.notificationSettings()
        
        switch notificationSettingsStatus.authorizationStatus
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
        
        return await MainActor.run {
            self.notificationStatus = notificationSettingsStatus
            
            return notificationSettingsStatus
        }
        
    }
    @discardableResult
    func requestNotificationAuthorization() async -> Bool
    {
        let notificationCenter = AppConstants.notificationCenter
        
        do
        {
            try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            
            return await MainActor.run {
                
                self.notificationEnabledInSystemSettings = true
                
                return true
            }
        }
        catch let notificationPermissionsObtainingError as NSError
        {
            print("Error: \(notificationPermissionsObtainingError.localizedDescription)")
            print("Error code: \(notificationPermissionsObtainingError.code)")
            
            return await MainActor.run {
                self.notificationEnabledInSystemSettings = false
                
                return false
            }
            
        }
    }
    
    // MARK: - Initiating the update process from legacy contexts
    @objc func startUpdateProcessForLegacySelectors(_ sender: NSMenuItem!) -> Void
    {
        self.isShowingUpdateSheet = true
        
        sendNotification(title: String(localized: "notification.upgrade-process-started"))
    }
}
