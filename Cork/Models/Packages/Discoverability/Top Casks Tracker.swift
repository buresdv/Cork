//
//  Top Casks Tracker.swift
//  Cork
//
//  Created by David Bureš on 19.08.2023.
//

import Foundation

class TopCasksTracker: ObservableObject
{
    @Published var topCasks: [BrewPackage] = .init()
}
