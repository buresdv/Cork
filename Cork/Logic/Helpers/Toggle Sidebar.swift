//
//  Toggle Sidebar.swift
//  Cork
//
//  Created by David Bureš on 21.02.2023.
//

import AppKit
import Foundation

func toggleSidebar()
{
    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
}
