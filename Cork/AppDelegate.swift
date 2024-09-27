//
//  AppDelegate.swift
//  Cork
//
//  Created by David Bureš on 07.07.2022.
//

import AppKit
import CorkShared
import DavidFoundation
import Foundation
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject
{
    @AppStorage("showInMenuBar") var showInMenuBar: Bool = false
    @AppStorage("startWithoutWindow") var startWithoutWindow: Bool = false

    @AppStorage("hasValidatedEmail") var hasValidatedEmail: Bool = false
    @AppStorage("hasFinishedLicensingWorkflow") var hasFinishedLicensingWorkflow: Bool = false

    @AppStorage("numberOfFailedLicenseRechecks") var numberOfFailedLicenseRechecks: Int = 0

    @MainActor let appState: AppState = .init()

    func applicationWillFinishLaunching(_: Notification)
    {
        if startWithoutWindow
        {
            NSApp.setActivationPolicy(.accessory)
        }
        else
        {
            NSApp.setActivationPolicy(.regular)
        }
    }

    func applicationDidFinishLaunching(_: Notification)
    {
        if startWithoutWindow
        {
            for window in NSApp.windows
            {
                window.close()
            }
        }

        #if !SELF_COMPILED
            Task
            {
                await self.recheckBoughtStatus()

                AppConstants.logger.debug("Number of failed rechecks: \(self.numberOfFailedLicenseRechecks)")
            }
        #endif
    }

    func applicationWillBecomeActive(_: Notification)
    {
        NSApp.setActivationPolicy(.regular)
    }

    func applicationWillUnhide(_: Notification)
    {
        NSApp.setActivationPolicy(.regular)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool
    {
        if showInMenuBar
        {
            NSApp.setActivationPolicy(.accessory)
            return false
        }
        else
        {
            NSApp.setActivationPolicy(.regular)
            return true
        }
    }

    func applicationWillTerminate(_: Notification)
    {
        AppConstants.logger.debug("Will die...")
        do
        {
            try saveTaggedIDsToDisk(appState: appState)
        }
        catch let dataSavingError as NSError
        {
            AppConstants.logger.error("Failed while trying to save data to disk: \(dataSavingError, privacy: .public)")
        }
        AppConstants.logger.debug("Died")
    }

    func applicationDockMenu(_: NSApplication) -> NSMenu?
    {
        let menu: NSMenu = .init()
        menu.autoenablesItems = false

        let updatePackagesMenuItem: NSMenuItem = .init()
        updatePackagesMenuItem.action = #selector(appState.startUpdateProcessForLegacySelectors(_:))
        updatePackagesMenuItem.target = appState

        if appState.isCheckingForPackageUpdates
        {
            updatePackagesMenuItem.title = String(localized: "start-page.updates.loading")
            updatePackagesMenuItem.isEnabled = false
        }
        else if appState.isShowingUpdateSheet
        {
            updatePackagesMenuItem.title = String(localized: "update-packages.updating.updating")
            updatePackagesMenuItem.isEnabled = false
        }
        else
        {
            updatePackagesMenuItem.title = String(localized: "navigation.menu.packages.update")
            updatePackagesMenuItem.isEnabled = true
        }

        menu.addItem(updatePackagesMenuItem)

        return menu
    }

    // MARK: - Private functions

    @MainActor
    private func recheckBoughtStatus() async
    {
        /// If the number of failed rechecks is lower than 10, return `true` so that the user is not pestered with having to add the license again. Otherwise, force the user to authenticate again
        if numberOfFailedLicenseRechecks > 3
        {
            AppConstants.logger.warning("Failed license recheck too many times: Will force new authentiation")

            appState.licensingState = .notBoughtOrHasNotActivatedDemo
            hasValidatedEmail = false
            hasFinishedLicensingWorkflow = false
        }
        else
        {
            guard let licenseEmail: String = AppConstants.keychain["licenseEmail"]
            else
            { /// If there is no email set at all, it means that it has not been saved (because this is the first recheck). In that case, force the user to authenticate again
                AppConstants.logger.warning("Email doesn't exist in keychain: Will force new authentication")

                appState.licensingState = .notBoughtOrHasNotActivatedDemo
                hasValidatedEmail = false
                hasFinishedLicensingWorkflow = false

                return
            }

            do
            {
                AppConstants.logger.debug("Will try to recheck license status with email: \(licenseEmail)")

                let authenticationResult: Bool = try await checkIfUserBoughtCork(for: licenseEmail)

                AppConstants.logger.debug("License recheck status: \(authenticationResult)")

                if authenticationResult == false
                {
                    AppConstants.logger.warning("Failed license recheck: Account doesn't exist. Will force new authentication immediately")

                    appState.licensingState = .notBoughtOrHasNotActivatedDemo
                    hasValidatedEmail = false
                    hasFinishedLicensingWorkflow = false
                }

                numberOfFailedLicenseRechecks = 0
            }
            catch let authenticationError as CorkLicenseRetrievalError
            {
                switch authenticationError
                {
                case .authorizationComplexNotEncodedProperly:
                    AppConstants.logger.warning("Failed license recheck: Authorization complex not encoded properly")

                case .notConnectedToTheInternet:
                    AppConstants.logger.warning("Failed license recheck: Not connected to the internet")

                case .operationTimedOut:
                    AppConstants.logger.warning("Failed license recheck: Operaiton timed out. Is the authenticaiton server offline?")

                case .otherError(let errorDescription):
                    AppConstants.logger.warning("Failed license recheck: Other error: \(errorDescription)")
                }

                numberOfFailedLicenseRechecks += 1
            }
            catch
            {
                AppConstants.logger.warning("Failed license recheck: Other error: \(error.localizedDescription)")

                numberOfFailedLicenseRechecks += 1
            }
        }
    }
}
