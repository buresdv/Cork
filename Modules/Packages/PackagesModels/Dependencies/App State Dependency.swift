//
//  App State Dependency.swift
//  Cork
//
//  Created by David Bureš - P on 07.03.2026.
//

import Foundation
import FactoryKit

public extension Container
{
    @MainActor
    var appState: Factory<AppState>
    {
        Factory(self)
        {
            AppState()
        }
        .singleton
    }
}
