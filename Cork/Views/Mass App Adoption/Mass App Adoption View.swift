//
//  Mass App Adoption View.swift
//  Cork
//
//  Created by David Bureš - P on 07.10.2025.
//

import SwiftUI

struct MassAppAdoptionView: View
{
    
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker
    
    var body: some View
    {
        SheetTemplate(isShowingTitle: true)
        {
            Text(String(brewPackagesTracker.adoptableAppsSelectedToBeAdopted.count))
        }
    }
}
