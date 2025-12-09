//
//  App Constants Dependency.swift
//  Cork
//
//  Created by David Bureš - P on 12.09.2025.
//

import FactoryKit

public extension Container
{
    var appConstants: Factory<AppConstants>
    {
        Factory(self)
        {
            AppConstants()
        }
    }
}
