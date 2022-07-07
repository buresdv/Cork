//
//  AppDelegate.swift
//  Cork
//
//  Created by David Bureš on 07.07.2022.
//

import Foundation
import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var aboutWindowController: NSWindowController?
    
    func showAboutPanel() {
        if aboutWindowController == nil {
            let styleMask: NSWindow.StyleMask = [. closable, .miniaturizable, .titled]
            let window = NSWindow()
            
            window.styleMask = styleMask
            window.title = "About \(AppConstantsLocal.appName)"
            window.contentView = NSHostingView(rootView: AboutView())
            
            aboutWindowController = NSWindowController(window: window)
        }
        
        aboutWindowController?.showWindow(aboutWindowController?.window)
    }
}
