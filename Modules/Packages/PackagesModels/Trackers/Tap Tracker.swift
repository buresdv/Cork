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
    public init()
    {
        self.addedTaps = .init()
    }
    
    public var addedTaps: [BrewTap]
}

public extension TapTracker
{
    var numberOfAddedTaps: Int
    {
        return self.addedTaps.count
    }
}
