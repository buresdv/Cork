//
//  Outdated Packages Tracker Dependency.swift
//  Cork
//
//  Created by David Bureš - P on 18.04.2026.
//

import Foundation
import FactoryKit

public extension Container
{
    @MainActor
    var outdatedPackagesTracker: Factory<OutdatedPackagesTracker>
    {
        Factory(self)
        {
            OutdatedPackagesTracker()
        }
        .singleton
    }
}
