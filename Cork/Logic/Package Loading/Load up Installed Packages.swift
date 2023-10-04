//
//  Load up Installed Packages.swift
//  Cork
//
//  Created by David Bureš on 11.02.2023.
//

import Foundation
import IdentifiedCollections

@MainActor
func loadUpPackages(whatToLoad: PackageType, appState: AppState) async -> IdentifiedArrayOf<BrewPackage>
{

    print("Started \(whatToLoad == .formula ? "Formula" : "Cask") loading task at \(Date())")

    switch whatToLoad {
        case .formula:
            appState.isLoadingFormulae = true
        case .cask:
            appState.isLoadingCasks = true
    }

    var contentsOfFolder: IdentifiedArrayOf<BrewPackage> = .init()

    switch whatToLoad {
        case .formula:
            contentsOfFolder = await getContentsOfFolder(targetFolder: AppConstants.brewCellarPath, appState: appState)
        case .cask:
            contentsOfFolder = await getContentsOfFolder(targetFolder: AppConstants.brewCaskPath, appState: appState)
    }

    var installedPackages: IdentifiedArrayOf<BrewPackage> = .init() // Empty the tracker in case there is already something in it

    for package in contentsOfFolder
    {
        installedPackages.append(package)
    }

    switch whatToLoad {
        case .formula:
            appState.isLoadingFormulae = false
        case .cask:
            appState.isLoadingCasks = false
    }

    print("Found \(whatToLoad == .formula ? "Formulae" : "Casks"): \(installedPackages)")

    print("Finished \(whatToLoad == .formula ? "Formula" : "Cask") loading task at \(Date())")

    return installedPackages
}
