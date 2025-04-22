//
//  Searching View.swift
//  Cork
//
//  Created by David Bureš on 20.08.2023.
//

import SwiftUI
import CorkShared

struct InstallationSearchingView: View, Sendable
{
    @Binding var packageRequested: String

    @ObservedObject var searchResultTracker: SearchResultTracker

    @Binding var packageInstallationProcessStep: PackageInstallationProcessSteps

    var body: some View
    {
        ProgressView("add-package.searching-\(packageRequested)")
            .task
            {
                let rawSearchResults: (foundFormulae: [BrewPackage], foundCasks: [BrewPackage]) = await searchForPackages(named: packageRequested)
                
                async let processedFoundFormulae: [BrewPackage] = await processRawSearchResults(trackingArray: rawSearchResults.foundFormulae)
                async let processedFoundCasks: [BrewPackage] = await processRawSearchResults(trackingArray: rawSearchResults.foundCasks)
                 
                searchResultTracker.foundFormulae = await processedFoundFormulae
                searchResultTracker.foundCasks = await processedFoundCasks
                
                packageInstallationProcessStep = .presentingSearchResults
            }
    }
    
    /// Searches for packages
    /// Returns a tuple containing two arrays of search results; one for found formulae, one for found casks
    func searchForPackages(named packageRequested: String) async -> (foundFormulae: [BrewPackage], foundCasks: [BrewPackage])
    {
        searchResultTracker.purge(type: .both)
        
        var foundFormulaeTracker: [BrewPackage] = .init()
        var foundCasksTracker: [BrewPackage] = .init()

        async let foundFormulae: [String] = searchForPackage(packageName: packageRequested, packageType: .formula)
        async let foundCasks: [String] = searchForPackage(packageName: packageRequested, packageType: .cask)

        for formula in await foundFormulae
        {
            foundFormulaeTracker.append(BrewPackage(name: formula, type: .formula, installedOn: nil, versions: [], sizeInBytes: nil, downloadCount: nil))
        }
        for cask in await foundCasks
        {
            foundCasksTracker.append(BrewPackage(name: cask, type: .cask, installedOn: nil, versions: [], sizeInBytes: nil, downloadCount: nil))
        }

        return (foundFormulaeTracker, foundCasksTracker)
    }
    
    /// Processes the raw array
    /// The result is an array where different versions of the same package have been consolidated into a single element of the array with multiple versions assigned to it, instead of an array where different versions of a package are different entires in the array
    func processRawSearchResults(trackingArray: [BrewPackage]) async -> [BrewPackage]
    {
        /// Temporary array where processed found search results will be put
        var tempArray: [BrewPackage] = .init()
        
        /// Let's loop over the unprocessed array to find duplicate packages
        for unprocessedFoundPackage in trackingArray
        {
            AppConstants.shared.logger.debug("Will try to process raw package name \(unprocessedFoundPackage.name)")
            
            /// Let's check if there's a version defined for this package, by checking if it contains a `@`. If it doesn't, just append the name of the package itself, because this means it doesn't have any specific versions defined.
            if !unprocessedFoundPackage.name.contains("@")
            {
                AppConstants.shared.logger.debug("Package name \(unprocessedFoundPackage.name) doesn't have a \"@\" character. Will place it directly into the tracker")
                
                tempArray.append(unprocessedFoundPackage)
            }
            else
            { /// If it has a version defined, split its `name@version` to separate its name from its version
                
                AppConstants.shared.logger.debug("Package name \(unprocessedFoundPackage.name) has a \"@\" character. Will process it")
                
                let splitPackageName: [String] = unprocessedFoundPackage.name.components(separatedBy: "@")
                
                let packageNameWithoutItsVersion: String = splitPackageName[0]
                let packageVersionWithoutItsName: String = splitPackageName[1]
                
                /// Let's see if there already is an identical package - We do this by finding the first index of a package inside the temporary array whose name matches this unprocessed package
                /// If it matches, it is already in the tracker, and we just need to add another version to it
                if let indexOfPreviouslyProcessedPackage = tempArray.firstIndex(where: { $0.name == packageNameWithoutItsVersion })
                {
                    tempArray[indexOfPreviouslyProcessedPackage].versions.append(packageVersionWithoutItsName)
                }
                else
                { /// If it doesn't match, it's not in the array yet. Let's add it to the array
                    tempArray.append(
                        .init(name: packageNameWithoutItsVersion, type: unprocessedFoundPackage.type, installedOn: nil, versions: [packageVersionWithoutItsName], sizeInBytes: nil, downloadCount: nil)
                    )
                }
            }
        }
        
        return tempArray
    }
}
