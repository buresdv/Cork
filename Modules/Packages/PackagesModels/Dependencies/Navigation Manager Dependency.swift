//
//  Navigation Manager Dependency.swift
//  CorkModels
//
//  Created by David Bureš - P on 16.03.2026.
//

import Foundation
import FactoryKit

public extension Container
{
    @MainActor
    var navigationManager: Factory<NavigationManager>
    {
        Factory(self)
        {
            NavigationManager()
        }
        .singleton
    }
}
