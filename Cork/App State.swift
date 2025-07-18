//
//  App State.swift
//  Cork
//
//  Created by David Bureš on 05.02.2023.
//

import AppKit
import Foundation
@preconcurrency import UserNotifications
import CorkShared
import CorkNotifications

/// Class that holds the global state of the app, excluding services
@MainActor
class AppState: ObservableObject
{
    // MARK: - Licensing

    @Published var licensingState: LicensingState = .notBoughtOrHasNotActivatedDemo

    // MARK: - Navigation

    @Published var navigationTargetId: UUID?

    // MARK: - Notifications

    @Published var notificationEnabledInSystemSettings: Bool?
    @Published var notificationAuthStatus: UNAuthorizationStatus = .notDetermined

    // MARK: - Stuff for controlling the UI in general

    @Published var isSearchFieldFocused: Bool = false

    // MARK: - Brewfile importing and exporting
    
    @Published var brewfileImportingStage: BrewfileImportStage = .importing

    @Published var isShowingUninstallationProgressView: Bool = false
    @Published var isShowingFatalError: Bool = false
    @Published var fatalAlertType: DisplayableAlert? = nil
    
    @Published var isShowingConfirmationDialog: Bool = false
    @Published var confirmationDialogType: ConfirmationDialog?
    
    @Published var sheetToShow: DisplayableSheet? = nil

    @Published var packageTryingToBeUninstalledWithSudo: BrewPackage?

    @Published var isShowingRemoveTapFailedAlert: Bool = false

    // MARK: - Loading of packages and taps
    @Published var isLoadingFormulae: Bool = true
    @Published var isLoadingCasks: Bool = true
    @Published var isLoadingTaps: Bool = true
    
    @Published var isLoadingTopPackages: Bool = false
    
    // MARK: - Loading errors
    @Published var failedWhileLoadingFormulae: Bool = false
    @Published var failedWhileLoadingCasks: Bool = false
    @Published var failedWhileLoadingTaps: Bool = false
    
    @Published var failedWhileLoadingTopPackages: Bool = false

    // MARK: - Tagging
    @Published var taggedPackageNames: Set<String> = .init()

    @Published var corruptedPackage: String = ""
    
    // MARK: - Other
    var enableExtraAnimations: Bool
    {
        return UserDefaults.standard.bool(forKey: "enableExtraAnimations")
    }

    // MARK: - Showing errors

    func showAlert(errorToShow: DisplayableAlert)
    {
        fatalAlertType = errorToShow

        isShowingFatalError = true
    }

    func dismissAlert()
    {
        isShowingFatalError = false

        fatalAlertType = nil
    }
    
    // MARK: - Showing sheets
    
    func showSheet(ofType sheetType: DisplayableSheet)
    {
        self.sheetToShow = sheetType
    }
    
    func dismissSheet()
    {
        self.sheetToShow = nil
    }

    // MARK: Showing confirmation dialogs
    
    func showConfirmationDialog(ofType confirmationDialogType: ConfirmationDialog)
    {
        self.confirmationDialogType = confirmationDialogType
        self.isShowingConfirmationDialog = true
    }
    
    func dismissConfirmationDialog()
    {
        self.isShowingConfirmationDialog = false
        self.confirmationDialogType = nil
    }
    
    // MARK: - Notification setup

    func setupNotifications() async
    {
        let notificationCenter: UNUserNotificationCenter = AppConstants.shared.notificationCenter

        let authStatus: UNAuthorizationStatus = await notificationCenter.authorizationStatus()

        switch authStatus
        {
        case .notDetermined:
            AppConstants.shared.logger.debug("Notification authorization status not determined. Will request notifications again")

            await requestNotificationAuthorization()

        case .denied:
            AppConstants.shared.logger.debug("Notifications were refused")

        case .authorized:
            AppConstants.shared.logger.debug("Notifications were authorized")

        case .provisional:
            AppConstants.shared.logger.debug("Notifications are provisional")

        case .ephemeral:
            AppConstants.shared.logger.debug("Notifications are ephemeral")

        @unknown default:
            AppConstants.shared.logger.error("Something got really fucked up about notifications setup")
        }

        notificationAuthStatus = authStatus
    }

    func requestNotificationAuthorization() async
    {
        let notificationCenter: UNUserNotificationCenter = AppConstants.shared.notificationCenter

        do
        {
            try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])

            notificationEnabledInSystemSettings = true
        }
        catch let notificationPermissionsObtainingError as NSError
        {
            AppConstants.shared.logger.error("Notification permissions obtaining error: \(notificationPermissionsObtainingError.localizedDescription, privacy: .public)\nError code: \(notificationPermissionsObtainingError.code, privacy: .public)")

            notificationEnabledInSystemSettings = false
        }
    }

    // MARK: - Initiating the update process from legacy contexts

    @objc func startUpdateProcessForLegacySelectors(_: NSMenuItem!)
    {
        self.showSheet(ofType: .fullUpdate)

        sendNotification(title: String(localized: "notification.upgrade-process-started"))
    }
}

private extension UNUserNotificationCenter
{
    func authorizationStatus() async -> UNAuthorizationStatus
    {
        await notificationSettings().authorizationStatus
    }
}
