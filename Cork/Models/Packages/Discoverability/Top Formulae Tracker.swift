//
//  Top Formulae Tracker.swift
//  Cork
//
//  Created by David Bureš on 19.08.2023.
//

import Foundation

class TopFormulaeTracker: ObservableObject
{
    @Published var topPackages: [BrewPackage] = .init()
}
