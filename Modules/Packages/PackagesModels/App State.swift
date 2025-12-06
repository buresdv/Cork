//
//  App State.swift
//  Cork
//
//  Created by David Bureš - P on 28.10.2025.
//

import AppKit
import CorkShared
import Foundation
import Observation
@preconcurrency import UserNotifications

/// Class that holds the global state of the app, excluding services
@Observable @MainActor
public final class AppState
{
    public init () {}
    
    // MARK: - Licensing
    
    public enum LicensingState
    {
        case notBoughtOrHasNotActivatedDemo

        case demo
        case bought

        case selfCompiled
    }

    public var licensingState: LicensingState = .notBoughtOrHasNotActivatedDemo

    /// Class for controlling the opened panes, and providing information about the status of the currently opened pane
    @Observable @MainActor
    public final class NavigationManager
    {
        /// Possible things to show in the detail pane
        /// Can be either a ``BrewPackage`` for a Formula or Cask, or ``BrewTap`` for a Tap
        public enum DetailDestination: Hashable
        {
            case package(package: BrewPackage)
            case tap(tap: BrewTap)
        }

        /// Which pane is opened in the detail
        public var openedScreen: DetailDestination?

        /// Dismiss the currently opened screen and return to the status page
        public func dismissScreen()
        {
            self.openedScreen = nil
        }

        /// Check whether any panes are currently opened
        public var isAnyScreenOpened: Bool
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

    public var navigationManager: NavigationManager = .init()

    // MARK: - Notifications

    public var notificationEnabledInSystemSettings: Bool?
    public var notificationAuthStatus: UNAuthorizationStatus = .notDetermined

    // MARK: - Stuff for controlling the UI in general

    public var isSearchFieldFocused: Bool = false

    // MARK: - Brewfile importing and exporting

    public var brewfileImportingStage: BrewfileImportStage = .importing

    public var isShowingUninstallationProgressView: Bool = false
    public var isShowingFatalError: Bool = false
    public var fatalAlertType: DisplayableAlert?

    public var isShowingConfirmationDialog: Bool = false
    public var confirmationDialogType: ConfirmationDialog?

    public var sheetToShow: DisplayableSheet?

    public var packageTryingToBeUninstalledWithSudo: BrewPackage?

    public var isShowingRemoveTapFailedAlert: Bool = false

    // MARK: - Loading of packages and taps

    public var isLoadingFormulae: Bool = true
    public var isLoadingCasks: Bool = true
    public var isLoadingTaps: Bool = true

    public var isLoadingTopPackages: Bool = false

    // MARK: - Loading errors

    public var failedWhileLoadingFormulae: Bool = false
    public var failedWhileLoadingCasks: Bool = false
    public var failedWhileLoadingTaps: Bool = false

    public var failedWhileLoadingTopPackages: Bool = false

    // MARK: - Tagging

    public var corruptedPackage: String = ""

    // MARK: - Other

    public var enableExtraAnimations: Bool
    {
        return UserDefaults.standard.bool(forKey: "enableExtraAnimations")
    }

    // MARK: - Showing errors

    public func showAlert(errorToShow: DisplayableAlert)
    {
        fatalAlertType = errorToShow

        isShowingFatalError = true
    }

    public func dismissAlert()
    {
        isShowingFatalError = false

        fatalAlertType = nil
    }

    // MARK: - Showing sheets

    public func showSheet(ofType sheetType: DisplayableSheet)
    {
        self.sheetToShow = sheetType
    }

    public func dismissSheet()
    {
        self.sheetToShow = nil
    }

    // MARK: Showing confirmation dialogs

    public func showConfirmationDialog(ofType confirmationDialogType: ConfirmationDialog)
    {
        self.confirmationDialogType = confirmationDialogType
        self.isShowingConfirmationDialog = true
    }

    public func dismissConfirmationDialog()
    {
        self.isShowingConfirmationDialog = false
        self.confirmationDialogType = nil
    }

    // MARK: - Notification setup

    public func setupNotifications() async
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

    public func requestNotificationAuthorization() async
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

    @objc public func startUpdateProcessForLegacySelectors(_: NSMenuItem!)
    {
        self.showSheet(ofType: .fullUpdate)

        //sendNotification(title: String(localized: "notification.upgrade-process-started"))
    }
}

private extension UNUserNotificationCenter
{
    func authorizationStatus() async -> UNAuthorizationStatus
    {
        await notificationSettings().authorizationStatus
    }
}
