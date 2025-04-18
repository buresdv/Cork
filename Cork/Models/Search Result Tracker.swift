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
    
    enum PurgeType
    {
        /// Purge the Formulae tracker
        case formula
        
        /// Purge the Cask tracker
        case cask
        
        /// Purge both the Formulae and Cask tracker
        case both
    }
    
    /// Clear the tracker
    func purge(type purgeType: PurgeType)
    {
        switch purgeType {
        case .formula:
            self.foundFormulae = .init()
        case .cask:
            self.foundCasks = .init()
        case .both:
            self.foundFormulae = .init()
            self.foundCasks = .init()
        }
    }
}
