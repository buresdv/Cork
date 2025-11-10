//
//  Search Result Tracker.swift
//  Cork
//
//  Created by David Bureš on 22.02.2023.
//

import Foundation
import CorkModels

@Observable
class SearchResultTracker
{
    /// These two have to be arrays because the order matters
    /// When searching, Homebrew returns the best result at the top
    var foundFormulae: [BrewPackage] = .init()
    var foundCasks: [BrewPackage] = .init()
    var selectedPackagesForInstallation: [String] = .init()
}
