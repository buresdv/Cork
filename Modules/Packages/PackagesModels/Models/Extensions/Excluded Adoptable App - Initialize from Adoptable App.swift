//
//  Excluded Adoptable App - Initialize from Adoptable App.swift
//  CorkModels
//
//  Created by David Bureš - P on 11.11.2025.
//

import CorkShared
import Foundation

public extension ExcludedAdoptableApp
{
    convenience init(fromAdoptableApp app: BrewPackagesTracker.AdoptableApp)
    {
        self.init(appExecutable: app.appExecutable)
    }
}
