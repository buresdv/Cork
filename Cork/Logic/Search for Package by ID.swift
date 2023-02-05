//
//  Search for Package by ID.swift
//  Cork
//
//  Created by David Bureš on 04.07.2022.
//

import Foundation

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
