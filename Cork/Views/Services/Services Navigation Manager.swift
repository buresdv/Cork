//
//  Services Navigation Manager.swift
//  Cork
//
//  Created by David Bureš - P on 31.07.2026.
//

import Foundation
import SwiftNavigation
import FactoryKit

@Observable @MainActor
public class ServicesNavigationManager
{
    @CasePathable
    public enum DetailDestination: Hashable
    {
        case service(service: HomebrewService)
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

public extension Container
{
    @MainActor
    var servicesNavigationManager: Factory<ServicesNavigationManager>
    {
        Factory(self)
        {
            ServicesNavigationManager()
        }
        .singleton
    }
}
