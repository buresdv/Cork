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
                
                async let processedFoundFormulae: [BrewPackage] = await searchResultTracker.processRawPackageArray(trackingArray: rawSearchResults.foundFormulae)
                async let processedFoundCasks: [BrewPackage] = await searchResultTracker.processRawPackageArray(trackingArray: rawSearchResults.foundCasks)
                 
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
}
