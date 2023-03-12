//
//  Load up Tapped Taps.swift
//  Cork
//
//  Created by David Bureš on 10.02.2023.
//

import Foundation

@MainActor
func loadUpTappedTaps() async -> [BrewTap]
{
    var finalAvailableTaps: [BrewTap] = .init()
    
    let availableTapsRaw = await shell(AppConstants.brewExecutablePath.absoluteString, ["tap"])
    
    let availableTaps = availableTapsRaw.standardOutput.components(separatedBy: "\n")
    
    for tap in availableTaps {
        if !tap.isEmpty
        {
            finalAvailableTaps.append(BrewTap(name: tap))
        }
    }
    
    return finalAvailableTaps
}
