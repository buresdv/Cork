//
//  Load up Casks.swift
//  Cork
//
//  Created by David Bureš on 11.02.2023.
//

import Foundation

@MainActor
func loadUpCasks(appState: AppState, sortBy: PackageSortingOptions) async -> [BrewPackage]
{
    print("Started Cask task at \(Date())")
    
    appState.isLoadingCasks = true
    
    let contentsOfCaskFolder = await getContentsOfFolder(targetFolder: AppConstantsLocal.brewCaskPath)

    var installedCasks = [BrewPackage]() // Empty the tracker in case there is already something in it

    for package in contentsOfCaskFolder
    {
        installedCasks.append(package)
    }

    appState.isLoadingCasks = false
    
    switch sortBy {
    case .none:
        break
    case .alphabetically:
        installedCasks = sortPackagesAlphabetically(installedCasks)
    case .byInstallDate:
        installedCasks = sortPackagesByInstallDate(installedCasks)
    }
    
    return installedCasks
}
