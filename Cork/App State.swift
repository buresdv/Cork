//
//  AppState.swift
//  Cork
//
//  Created by David Bureš on 05.02.2023.
//

import Foundation
import AppKit
@preconcurrency import UserNotifications

/// Class that holds the global state of the app, excluding services
@MainActor
class AppState: ObservableObject 
{
    // MARK: - Licensing
    @Published var licensingState: LicensingState = .notBoughtOrHasNotActivatedDemo
    @Published var isShowingLicensingSheet: Bool = false
    
    // MARK: - Navigation
    @Published var navigationSelection: UUID?
    
    // MARK: - Notifications
    @Published var notificationEnabledInSystemSettings: Bool?
    @Published var notificationAuthStatus: UNAuthorizationStatus = .notDetermined
    
    // MARK: - Stuff for controlling various sheets from the menu bar
    @Published var isShowingInstallationSheet: Bool = false
    @Published var isShowingPackageReinstallationSheet: Bool = false
    @Published var isShowingUninstallationSheet: Bool = false
    @Published var isShowingMaintenanceSheet: Bool = false
    @Published var isShowingFastCacheDeletionMaintenanceView: Bool = false
    @Published var isShowingAddTapSheet: Bool = false
    @Published var isShowingUpdateSheet: Bool = false
    
    // MARK: - Stuff for controlling the UI in general
    @Published var isSearchFieldFocused: Bool = false
    
    // MARK: - Brewfile importing and exporting
    @Published var isShowingBrewfileExportProgress: Bool = false
    @Published var isShowingBrewfileImportProgress: Bool = false
    @Published var brewfileImportingStage: BrewfileImportStage = .importing
    
    @Published var isCheckingForPackageUpdates: Bool = false
    
    @Published var isShowingUninstallationProgressView: Bool = false
    @Published var isShowingFatalError: Bool = false
    @Published var fatalAlertType: FatalAlertType = .couldNotApplyTaggedStateToPackages
    
    @Published var isShowingSudoRequiredForUninstallSheet: Bool = false
    @Published var packageTryingToBeUninstalledWithSudo: BrewPackage?
    
    @Published var offendingDependencyProhibitingUninstallation: String = ""
    @Published var offendingTapProhibitingRemovalOfTap: String = ""
    @Published var isShowingRemoveTapFailedAlert: Bool = false
    
    @Published var isShowingIncrementalUpdateSheet: Bool = false
    
    @Published var isLoadingFormulae: Bool = true
    @Published var isLoadingCasks: Bool = true
    
    @Published var isLoadingTopPackages: Bool = false
    @Published var failedWhileLoadingTopPackages: Bool = false
    
    @Published var cachedDownloadsFolderSize: Int64 = directorySize(url: AppConstants.brewCachedDownloadsPath)
    @Published var cachedDownloads: [CachedDownload] = .init()
    
    private var cachedDownloadsTemp: [CachedDownload] = .init()
    
    @Published var taggedPackageNames: Set<String> = .init()
    
    @Published var corruptedPackage: String = ""
    
    // MARK: - Showing errors
    func showAlert(errorToShow: FatalAlertType)
    {
        self.fatalAlertType = errorToShow
        
        self.isShowingFatalError = true
    }
    
    func dismissAlert()
    {
        self.isShowingFatalError = false
    }
    
    // MARK: - Notification setup
    func setupNotifications() async
    {
        let notificationCenter = AppConstants.notificationCenter
        
        let authStatus = await notificationCenter.authorizationStatus()

        switch authStatus
        {
            case .notDetermined:
                AppConstants.logger.debug("Notification authorization status not determined. Will request notifications again")
                
                await self.requestNotificationAuthorization()
            case .denied:
                AppConstants.logger.debug("Notifications were refused")
            case .authorized:
                AppConstants.logger.debug("Notifications were authorized")
                
            case .provisional:
                AppConstants.logger.debug("Notifications are provisional")
                
            case .ephemeral:
                AppConstants.logger.debug("Notifications are ephemeral")
                
            @unknown default:
                AppConstants.logger.error("Something got really fucked up about notifications setup")
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
            AppConstants.logger.error("Notification permissions obtaining error: \(notificationPermissionsObtainingError.localizedDescription, privacy: .public)\nError code: \(notificationPermissionsObtainingError.code, privacy: .public)")
            
            notificationEnabledInSystemSettings = false
        }
    }
    
    // MARK: - Initiating the update process from legacy contexts
    @objc func startUpdateProcessForLegacySelectors(_ sender: NSMenuItem!) -> Void
    {
        self.isShowingUpdateSheet = true
        
        sendNotification(title: String(localized: "notification.upgrade-process-started"))
    }
    
    func setCouldNotParseTopPackages() {
        showAlert(errorToShow: .couldNotParseTopPackages)
    }
    
    func loadCachedDownloadedPackages() async
    {
        let smallestDispalyableSize: Int = Int(self.cachedDownloadsFolderSize / 50)
        
        var packagesThatAreTooSmallToDisplaySize: Int = 0
        
        guard let cachedDownloadsFolderContents: [URL] = try? FileManager.default.contentsOfDirectory(at: AppConstants.brewCachedDownloadsPath, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles]) else
        {
            return
        }
        
        let usableCachedDownloads: [URL] = cachedDownloadsFolderContents.filter({ $0.pathExtension != "json" })
        
        for usableCachedDownload in usableCachedDownloads
        {
            guard var itemName: String = try? regexMatch(from: usableCachedDownload.lastPathComponent, regex: "(?<=--)(.*?)(?=\\.)") else
            {
                return
            }
            
            AppConstants.logger.debug("Temp item name: \(itemName, privacy: .public)")
            
            if itemName.contains("--")
            {
                do
                {
                    itemName = try regexMatch(from: itemName, regex: ".*?(?=--)")
                }
                catch
                {
                    
                }
            }
            
            guard let itemAttributes = try? FileManager.default.attributesOfItem(atPath: usableCachedDownload.path) else
            {
                return
            }
            
            guard let itemSize = itemAttributes[.size] as? Int else
            {
                return
            }
            
            if itemSize < smallestDispalyableSize
            {
                packagesThatAreTooSmallToDisplaySize = packagesThatAreTooSmallToDisplaySize + itemSize
            }
            else
            {
                self.cachedDownloads.append(CachedDownload(packageName: itemName, sizeInBytes: itemSize))
            }
            
            AppConstants.logger.debug("Others size: \(packagesThatAreTooSmallToDisplaySize, privacy: .public)")
        }
        
        AppConstants.logger.log("Cached downloads contents: \(self.cachedDownloads)")
        
        self.cachedDownloads = self.cachedDownloads.sorted(by: { $0.sizeInBytes < $1.sizeInBytes })
        
        self.cachedDownloads.append(.init(packageName: String(localized: "start-page.cached-downloads.graph.other-smaller-packages"), sizeInBytes: packagesThatAreTooSmallToDisplaySize, packageType: .other))
    }
}

private extension UNUserNotificationCenter {
    func authorizationStatus() async -> UNAuthorizationStatus {
        await notificationSettings().authorizationStatus
    }
}


extension AppState
{
    func assignPackageTypeToCachedDownloads(brewData: BrewDataStorage) -> Void
    {
        var cachedDownloadsTracker: [CachedDownload] = .init()
        
        AppConstants.logger.debug("Package tracker in cached download assignment function has \(brewData.installedFormulae.count + brewData.installedCasks.count) packages")
        
        for cachedDownload in self.cachedDownloads
        {
            if brewData.installedFormulae.contains(where: { $0.name.localizedCaseInsensitiveContains(cachedDownload.packageName.onlyLetters) })
            { /// The cached package is a formula
                AppConstants.logger.debug("Cached package \(cachedDownload.packageName) is a formula")
                cachedDownloadsTracker.append(.init(packageName: cachedDownload.packageName, sizeInBytes: cachedDownload.sizeInBytes, packageType: .formula))
            }
            else if brewData.installedCasks.contains(where: { $0.name.localizedCaseInsensitiveContains(cachedDownload.packageName.onlyLetters) })
            { /// The cached package is a cask
                AppConstants.logger.debug("Cached package \(cachedDownload.packageName) is a cask")
                cachedDownloadsTracker.append(.init(packageName: cachedDownload.packageName, sizeInBytes: cachedDownload.sizeInBytes, packageType: .cask))
            }
            else
            { /// The cached package cannot be found
                AppConstants.logger.debug("Cached package \(cachedDownload.packageName) is unknown")
                cachedDownloadsTracker.append(.init(packageName: cachedDownload.packageName, sizeInBytes: cachedDownload.sizeInBytes, packageType: .unknown))
            }
        }
        
        self.cachedDownloads = cachedDownloadsTracker
    }
}
