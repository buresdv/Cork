//
//  Search Result Tracker.swift
//  Cork
//
//  Created by David Bureš on 22.02.2023.
//

import Foundation
import IdentifiedCollections

class SearchResultTracker: ObservableObject
{
    @Published var foundFormulae: IdentifiedArrayOf<BrewPackage> = .init()
    @Published var foundCasks: IdentifiedArrayOf<BrewPackage> = .init()
    @Published var selectedPackagesForInstallation: [String] = .init()
}
