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
    
    var appState = AppState()
    
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool
    {
        if showInMenuBar
        {
            return false
        }
        else
        {
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
        
        let updatePackagesMenuItem = NSMenuItem()
        updatePackagesMenuItem.title = String(localized: "navigation.menu.packages.update")
        updatePackagesMenuItem.action = #selector(appState.startUpdateProcessForLegacySelectors(_:))
        updatePackagesMenuItem.target = appState
        
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
