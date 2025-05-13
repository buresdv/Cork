//
//  Tap Tracker.swift
//  Cork
//
//  Created by David Bureš - P on 13.05.2025.
//

import Foundation
import Observation

@Observable @MainActor
class TapTracker
{
    var addedTaps: [BrewTap] = .init()
}

extension TapTracker
{
    var numberOfAddedTaps: Int
    {
        return self.addedTaps.count
    }
}
