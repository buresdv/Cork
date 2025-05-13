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

@Observable
class AppDelegate: NSObject, NSApplicationDelegate
{
    @ObservationIgnored @AppStorage("showInMenuBar") var showInMenuBar: Bool = false
    @ObservationIgnored @AppStorage("startWithoutWindow") var startWithoutWindow: Bool = false

    @MainActor let appState: AppState = .init()

    func applicationWillFinishLaunching(_: Notification)
    {
        if startWithoutWindow
        {
            startWithoutWindow = false
        }
        // TODO: Enable again once Apple fixes issue raised in ticket #408
        /*
        if startWithoutWindow
        {
            NSApp.setActivationPolicy(.accessory)
        }
        else
        {
            NSApp.setActivationPolicy(.regular)
        }
         */
    }

    func applicationDidFinishLaunching(_: Notification)
    {
        // TODO: Enable again once Apple fixes issue raised in ticket #408
        /*
        if startWithoutWindow
        {
            for window in NSApp.windows
            {
                window.close()
            }
        }
         */
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
            // TODO: Enable again once Apple fixes issue raised in ticket #408
            // NSApp.setActivationPolicy(.accessory)
            return false
        }
        else
        {
            // TODO: Enable again once Apple fixes issue raised in ticket #408
            // NSApp.setActivationPolicy(.regular)
            return true
        }
    }

    /*
    func applicationDockMenu(_: NSApplication) -> NSMenu?
    {
        let menu: NSMenu = .init()
        menu.autoenablesItems = false

        let updatePackagesMenuItem: NSMenuItem = .init()
        updatePackagesMenuItem.action = #selector(appState.startUpdateProcessForLegacySelectors(_:))
        updatePackagesMenuItem.target = appState

        if outdatedPackageTracker.isCheckingForPackageUpdates
        {
            updatePackagesMenuItem.title = String(localized: "start-page.updates.loading")
            updatePackagesMenuItem.isEnabled = false
        }
        else if appState.sheetToShow == .fullUpdate
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
     */
}
