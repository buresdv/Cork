//
//  Load up Installed Packages.swift
//  Cork
//
//  Created by David Bureš on 11.02.2023.
//

import Foundation


@MainActor
func loadUpPackages(whatToLoad: PackageType, appState: AppState) async -> Set<BrewPackage>
{

    AppConstants.logger.info("Started \(whatToLoad == .formula ? "Formula" : "Cask", privacy: .public) loading task at \(Date(), privacy: .public)")

    var contentsOfFolder: Set<BrewPackage> = .init()

    switch whatToLoad {
        case .formula:
            contentsOfFolder = await getContentsOfFolder(targetFolder: AppConstants.brewCellarPath, appState: appState)
        case .cask:
            contentsOfFolder = await getContentsOfFolder(targetFolder: AppConstants.brewCaskPath, appState: appState)
    }

    var installedPackages: Set<BrewPackage> = .init() // Empty the tracker in case there is already something in it

    for package in contentsOfFolder
    {
        installedPackages.insert(package)
    }

    AppConstants.logger.info("Found \(whatToLoad == .formula ? "Formulae" : "Casks", privacy: .public): \(installedPackages)")

    AppConstants.logger.info("Finished \(whatToLoad == .formula ? "Formula" : "Cask", privacy: .public) loading task at \(Date(), privacy: .auto)")

    return installedPackages
}
