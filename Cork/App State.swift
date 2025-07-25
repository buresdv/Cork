//
//  App State.swift
//  Cork
//
//  Created by David Bureš on 05.02.2023.
//

import AppKit
import CorkNotifications
import CorkShared
import Foundation
import Observation
@preconcurrency import UserNotifications

/// Class that holds the global state of the app, excluding services
@Observable @MainActor
final class AppState
{
    // MARK: - Licensing

    var licensingState: LicensingState = .notBoughtOrHasNotActivatedDemo

    /// Class for controlling the opened panes, and providing information about the status of the currently opened pane
    @Observable @MainActor
    final class NavigationManager
    {
        /// Possible things to show in the detail pane
        /// Can be either a ``BrewPackage`` for a Formula or Cask, or ``BrewTap`` for a Tap
        enum DetailDestination: Hashable
        {
            case package(package: BrewPackage)
            case tap(tap: BrewTap)
        }

        /// Which pane is opened in the detail
        var openedScreen: DetailDestination?

        /// Dismiss the currently opened screen and return to the status page
        func dismissScreen()
        {
            self.openedScreen = nil
        }

        /// Check whether any panes are currently opened
        var isAnyScreenOpened: Bool
        {
            if self.openedScreen == nil
            {
                return false
            }
            else
            {
                return true
            }
        }
    }

    var navigationManager: NavigationManager = .init()

    // MARK: - Notifications

    var notificationEnabledInSystemSettings: Bool?
    var notificationAuthStatus: UNAuthorizationStatus = .notDetermined

    // MARK: - Stuff for controlling the UI in general

    var isSearchFieldFocused: Bool = false

    // MARK: - Brewfile importing and exporting

    var brewfileImportingStage: BrewfileImportStage = .importing

    var isShowingUninstallationProgressView: Bool = false
    var isShowingFatalError: Bool = false
    var fatalAlertType: DisplayableAlert?

    var isShowingConfirmationDialog: Bool = false
    var confirmationDialogType: ConfirmationDialog?

    var sheetToShow: DisplayableSheet?

    var packageTryingToBeUninstalledWithSudo: BrewPackage?

    var isShowingRemoveTapFailedAlert: Bool = false

    // MARK: - Loading of packages and taps

    var isLoadingFormulae: Bool = true
    var isLoadingCasks: Bool = true
    var isLoadingTaps: Bool = true

    var isLoadingTopPackages: Bool = false

    // MARK: - Loading errors

    var failedWhileLoadingFormulae: Bool = false
    var failedWhileLoadingCasks: Bool = false
    var failedWhileLoadingTaps: Bool = false

    var failedWhileLoadingTopPackages: Bool = false

    // MARK: - Tagging

    var corruptedPackage: String = ""

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
