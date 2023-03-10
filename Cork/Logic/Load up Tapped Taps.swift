//
//  Load up Tapped Taps.swift
//  Cork
//
//  Created by David Bureš on 10.02.2023.
//

import Foundation

@MainActor
func loadUpTappedTaps(into tracker: AvailableTaps) async -> Void
{
    let availableTapsRaw = await shell(AppConstants.brewExecutablePath.absoluteString, ["tap"])
    
    let availableTaps = availableTapsRaw.standardOutput.components(separatedBy: "\n")
    
    for tap in availableTaps {
        tracker.addedTaps.append(BrewTap(name: tap))
    }
}
