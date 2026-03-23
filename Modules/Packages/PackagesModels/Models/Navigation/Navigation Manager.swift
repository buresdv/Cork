//
//  Navigation Manager.swift
//  Cork
//
//  Created by David Bureš - P on 19.03.2026.
//

import Foundation
import SwiftNavigation

/// Class for controlling the opened panes, and providing information about the status of the currently opened pane
@Observable @MainActor
public final class NavigationManager
{
    /// Possible things to show in the detail pane
    /// Can be either a ``BrewPackage`` for a Formula or Cask, or ``BrewTap`` for a Tap
    @CasePathable
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
