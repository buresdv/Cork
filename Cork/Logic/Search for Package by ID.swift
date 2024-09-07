//
//  Search for Package by ID.swift
//  Cork
//
//  Created by David Bureš on 04.07.2022.
//

import Foundation
import CorkShared

private enum PackageRetrievalByUUIDError: LocalizedError
{
    case couldNotfindAnypackagesInTracker

    var errorDescription: String?
    {
        switch self
        {
        case .couldNotfindAnypackagesInTracker:
            return String(localized: "error.package-retrieval.uuid.could-not-find-any-packages-in-tracker")
        }
    }
}

extension UUID
{
    func getPackage(tracker: SearchResultTracker) throws -> BrewPackage
    {
        var filteredPackage: BrewPackage?
        
        AppConstants.logger.log("Formula tracker: \(tracker.foundFormulae.count)")
        AppConstants.logger.log("Cask tracker: \(tracker.foundCasks.count)")
        
        if !tracker.foundFormulae.isEmpty
        {
            filteredPackage = tracker.foundFormulae.filter { $0.id == self }.first
        }
        
        if filteredPackage == nil
        {
            filteredPackage = tracker.foundCasks.filter { $0.id == self }.first
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
}

enum TopPackageRetrievalError: LocalizedError
{
    case resultingArrayWasEmptyEvenThoughPackagesWereInIt

    var errorDescription: String?
    {
        switch self
        {
        case .resultingArrayWasEmptyEvenThoughPackagesWereInIt:
            return String(localized: "error.top-packages.impossible-error")
        }
    }
}

@MainActor
func getTopPackageFromUUID(requestedPackageUUID: UUID, packageType: PackageType, topPackageTracker: TopPackagesTracker) throws -> BrewPackage
{
    if packageType == .formula
    {
        guard let foundTopFormula: TopPackage = topPackageTracker.topFormulae.filter({ $0.id == requestedPackageUUID }).first
        else
        {
            throw TopPackageRetrievalError.resultingArrayWasEmptyEvenThoughPackagesWereInIt
        }

        return .init(name: foundTopFormula.packageName, type: .formula, installedOn: nil, versions: [], sizeInBytes: nil)
    }
    else
    {
        guard let foundTopCask: TopPackage = topPackageTracker.topCasks.filter({ $0.id == requestedPackageUUID }).first
        else
        {
            throw TopPackageRetrievalError.resultingArrayWasEmptyEvenThoughPackagesWereInIt
        }

        return .init(name: foundTopCask.packageName, type: .cask, installedOn: nil, versions: [], sizeInBytes: nil)
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
