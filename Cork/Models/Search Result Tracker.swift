//
//  Search Result Tracker.swift
//  Cork
//
//  Created by David Bureš on 22.02.2023.
//

import Foundation

class SearchResultTracker: ObservableObject
{
    /// These two have to be arrays because the order matters
    /// When searching, Homebrew returns the best result at the top
    @Published var foundFormulae: [BrewPackage] = .init()
    @Published var foundCasks: [BrewPackage] = .init()
    @Published var selectedPackagesForInstallation: [String] = .init()
}
