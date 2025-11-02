//
//  Tap Tracker.swift
//  Cork
//
//  Created by David Bureš - P on 13.05.2025.
//

import Foundation
import Observation

@Observable @MainActor
public class TapTracker
{
    var addedTaps: [BrewTap] = .init()
}

public extension TapTracker
{
    var numberOfAddedTaps: Int
    {
        return self.addedTaps.count
    }
}
