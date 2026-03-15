//
//  Brewfile Manager Dependency.swift
//  Cork
//
//  Created by David Bureš - P on 15.03.2026.
//

import Foundation
import FactoryKit

public extension Container
{
    var brewfileManager: Factory<BrewfileManager>
    {
        Factory(self)
        {
            BrewfileManager()
        }
    }
}
