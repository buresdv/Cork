//
//  Switch Cork to Foreground.swift
//  Cork
//
//  Created by David Bureš on 30.03.2024.
//

import Foundation
import AppKit

func switchCorkToForeground()
{
    if #available(macOS 14.0, *)
    {
        NSApp.activate(ignoringOtherApps: true)
    }
    else
    {
        let runningApps: [NSRunningApplication] = NSWorkspace.shared.runningApplications
        
        for app in runningApps
        {
            if app.localizedName == "Cork"
            {
                if !app.isActive
                {
                    app.activate(options: .activateIgnoringOtherApps)
                }
            }
        }
    }
    }
