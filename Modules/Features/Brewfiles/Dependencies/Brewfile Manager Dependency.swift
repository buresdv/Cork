//
//  Brewfile Manager Dependency.swift
//  Cork
//
//  Created by David Bureš - P on 29.03.2026.
//

import Foundation
import FactoryKit

public extension Container
{
    @MainActor
    var brewfileManager: Factory<BrewfileManager>
    {
        Factory(self)
        {
            BrewfileManager()
        }
        .singleton
    }
}
