//
//  Load up Formulae.swift
//  Cork
//
//  Created by David Bureš on 11.02.2023.
//

import Foundation

@MainActor
func loadUpFormulae(appState: AppState) async -> [BrewPackage]
{
    print("Started Cellar task at \(Date())")
    
    appState.isLoadingFormulae = true

    let contentsOfCellarFolder = await getContentsOfFolder(targetFolder: AppConstantsLocal.brewCellarPath)

    var installedFormulae = [BrewPackage]() // Empty the tracker in case there is already something in it

    for package in contentsOfCellarFolder
    {
        installedFormulae.append(package)
    }

    appState.isLoadingFormulae = false

    return installedFormulae
}
