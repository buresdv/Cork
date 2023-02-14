//
//  Search for Package by ID.swift
//  Cork
//
//  Created by David Bureš on 04.07.2022.
//

import Foundation

func getPackageFromUUID(requestedPackageUUID: UUID, tracker: SearchResultTracker) -> BrewPackage
{
    
    var filteredPackage: BrewPackage?
    
    let foundFormulae: [BrewPackage] = tracker.foundFormulae
    let foundCasks: [BrewPackage] = tracker.foundCasks
    
    for formula in foundFormulae {
        if requestedPackageUUID == formula.id
        {
            filteredPackage = BrewPackage(name: formula.name, isCask: formula.isCask, installedOn: formula.installedOn, versions: formula.versions, sizeInBytes: formula.sizeInBytes)
        }
    }
    
    for cask in foundCasks {
        if requestedPackageUUID == cask.id {
            filteredPackage = BrewPackage(name: cask.name, isCask: cask.isCask, installedOn: cask.installedOn, versions: cask.versions, sizeInBytes: cask.sizeInBytes)
        }
    }
    
    return filteredPackage!
}

/*
func getPackageNamesFromUUID(selectionBinding: Set<UUID>, tracker: SearchResultTracker) -> [String]
{
    let foundFormulae: [SearchResult] = tracker.foundFormulae
    let foundCasks: [SearchResult] = tracker.foundCasks

    var resultArray = [String]()

    for selection in selectionBinding
    {
        /// Step 1: Look through formulae
        for item in foundFormulae
        {
            if selection == item.id
            {
                resultArray.append(item.packageName)
            }
        }

        /// Step 2: Look through casks
        for item in foundCasks
        {
            if selection == item.id
            {
                resultArray.append(item.packageName)
            }
        }
    }

    return resultArray
}
*/
