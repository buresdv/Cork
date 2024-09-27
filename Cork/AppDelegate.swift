//
//  AppDelegate.swift
//  Cork
//
//  Created by David Bureš on 07.07.2022.
//

import AppKit
import DavidFoundation
import Foundation
import SwiftUI
import CorkShared
import KeychainAccess

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject
{
    @AppStorage("showInMenuBar") var showInMenuBar: Bool = false
    @AppStorage("startWithoutWindow") var startWithoutWindow: Bool = false
    
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
        
        let semaphore: DispatchSemaphore = .init(value: 0)
        
        Task
        {
            let licenseRecheckResult: Bool = await recheckBoughtStatus()
            
            AppConstants.logger.debug("License recheck status: \(licenseRecheckResult)")
            AppConstants.logger.debug("Number of failed rechecks: \(self.numberOfFailedLicenseRechecks)")
            
            semaphore.signal()
        }
        
        semaphore.wait()
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
    @MainActor @discardableResult
    private func recheckBoughtStatus() async -> Bool
    {
        /// If the number of failed rechecks is lower than 10, return `true` so that the user is not pestered with having to add the license again. Otherwise, force the user to authenticate again
        if numberOfFailedLicenseRechecks > 10
        {
            AppConstants.logger.debug("Failed license recheck too many times: Will force new authentiation")
            
            appState.licensingState = .notBoughtOrHasNotActivatedDemo
            
            return false
        }
        else
        {
            if appState.licensingState == .bought
            { /// Only run this if the user activated the app before
              
                guard let licenseEmail: String = AppConstants.keychain["licenseEmail"] else
                { /// If there is no email set at all, it means that it has not been saved (because this is the first recheck). In that case, force the user to authenticate again
                  
                    AppConstants.logger.debug("Email doesn't exist in keychain: Will force new authentication")
                    
                    appState.licensingState = .notBoughtOrHasNotActivatedDemo
                    
                    return false
                }
                
                do
                {
                    let authenticationResult: Bool = try await checkIfUserBoughtCork(for: licenseEmail)
                    
                    AppConstants.logger.debug("License recheck status: \(authenticationResult)")
                    
                    return authenticationResult
                }
                catch let authenticationError as CorkLicenseRetrievalError
                {
                    switch authenticationError
                    {
                        case .authorizationComplexNotEncodedProperly:
                            AppConstants.logger.error("Failed license recheck: Authorization complex not encoded properly")
                            
                            numberOfFailedLicenseRechecks += 1
                            return true
                            
                        case .notConnectedToTheInternet:
                            AppConstants.logger.error("Failed license recheck: Not connected to the internet")
                            
                            numberOfFailedLicenseRechecks += 1
                            return true
                            
                        case .operationTimedOut:
                            AppConstants.logger.error("Failed license recheck: Operaiton timed out. Is the authenticaiton server offline?")
                            
                            numberOfFailedLicenseRechecks += 1
                            return true
                            
                        case .otherError(let errorDescription):
                            AppConstants.logger.error("Failed license recheck: Other error: \(errorDescription)")
                            
                            numberOfFailedLicenseRechecks += 1
                            return true
                    }
                }
                catch let error
                {
                    AppConstants.logger.error("Failed license recheck: Other error: \(error.localizedDescription)")
                    
                    numberOfFailedLicenseRechecks += 1
                    return true
                }
            }
            else
            {
                return true
            }
        }
    }
}
