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

class AppDelegate: NSObject, NSApplicationDelegate
{
    @AppStorage("showInMenuBar") var showInMenuBar = false
    @AppStorage("startWithoutWindow") var startWithoutWindow: Bool = false
    
    @MainActor let appState = AppState()
    
    func applicationWillFinishLaunching(_ notification: Notification) 
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
    
    func applicationDidFinishLaunching(_ notification: Notification) 
    {
        if startWithoutWindow
        {
            if let window = NSApplication.shared.windows.first {
                window.close()
            }
        }
    }
    
    func applicationWillBecomeActive(_ notification: Notification) 
    {
        NSApp.setActivationPolicy(.regular)
    }
    func applicationWillUnhide(_ notification: Notification) 
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

    func applicationWillTerminate(_ notification: Notification) {
        print("Will die...")
        do
        {
            try saveTaggedIDsToDisk(appState: appState)
        }
        catch let dataSavingError as NSError
        {
            print("Failed while trying to save data to disk: \(dataSavingError)")
        }
        print("Died")
    }
    
    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        let menu = NSMenu()
        menu.autoenablesItems = false
        
        let updatePackagesMenuItem = NSMenuItem()
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
    
    private var aboutWindowController: NSWindowController?

    func showAboutPanel()
    {
        if aboutWindowController == nil
        {
            let styleMask: NSWindow.StyleMask = [.closable, .miniaturizable, .titled]
            let window = NSWindow()

            window.styleMask = styleMask
            window.title = NSLocalizedString("about.title", comment: "")
            window.contentView = NSHostingView(rootView: AboutView())

            aboutWindowController = NSWindowController(window: window)
        }
        aboutWindowController?.window?.center()
        aboutWindowController?.showWindow(aboutWindowController?.window)
    }
}
