//
//  Search for Package by ID.swift
//  Cork
//
//  Created by David Bureš on 04.07.2022.
//

import Foundation


private enum PackageRetrievalByUUIDError: Error
{
    case couldNotfindAnypackagesInTracker
}

func getPackageFromUUID(requestedPackageUUID: UUID, tracker: SearchResultTracker) throws -> BrewPackage
{
    
    var filteredPackage: BrewPackage?


    AppConstants.logger.log("Formula tracker: \(tracker.foundFormulae.count)")
    AppConstants.logger.log("Cask tracker: \(tracker.foundCasks.count)")

    if tracker.foundFormulae.count != 0
    {
        filteredPackage = tracker.foundFormulae.filter({ $0.id == requestedPackageUUID }).first
    }

    if filteredPackage == nil
    {
        filteredPackage = tracker.foundCasks.filter({ $0.id == requestedPackageUUID }).first
    }
    
    if let filteredPackage
    {
        return filteredPackage
    }
    else
    {
        throw PackageRetrievalByUUIDError.couldNotfindAnypackagesInTracker
    }
}

enum TopPackageRetrievalError: Error
{
    case resultingArrayWasEmptyEvenThoughPackagesWereInIt
}

func getTopPackageFromUUID(requestedPackageUUID: UUID, isCask: Bool, topPackageTracker: TopPackagesTracker) throws -> BrewPackage
{
    if !isCask
    {
        guard let foundTopFormula: TopPackage = topPackageTracker.topFormulae.filter({ $0.id == requestedPackageUUID }).first else
        {
            throw TopPackageRetrievalError.resultingArrayWasEmptyEvenThoughPackagesWereInIt
        }
        
        return BrewPackage(name: foundTopFormula.packageName, isCask: isCask, installedOn: nil, versions: [], sizeInBytes: nil)
    }
    else
    {
        guard let foundTopCask: TopPackage = topPackageTracker.topCasks.filter({ $0.id == requestedPackageUUID }).first else
        {
            throw TopPackageRetrievalError.resultingArrayWasEmptyEvenThoughPackagesWereInIt
        }
        
        return BrewPackage(name: foundTopCask.packageName, isCask: isCask, installedOn: nil, versions: [], sizeInBytes: nil)
    }
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
