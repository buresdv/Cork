//
//  Brew Packages Tracker Dependency.swift
//  Cork
//
//  Created by David Bureš - P on 09.01.2026.
//

import Foundation
import FactoryKit

public extension Container
{
    var brewPackagesTracker: Factory<BrewPackagesTracker>
    {
        Factory(self)
        { @Sendable in
            BrewPackagesTracker()
        }
    }
}
