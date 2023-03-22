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
    
    var appState = AppState()
    
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool
    {
        return true
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
