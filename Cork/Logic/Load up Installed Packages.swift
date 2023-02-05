//
//  Load up Installed Packages.swift
//  Cork
//
//  Created by David Bureš on 09.07.2022.
//

import Foundation

@MainActor
func loadUpInstalledPackages(into brewData: BrewDataStorage) async
{
    Task
    { // Task that gets the contents of the Cellar folder
        print("Started Cellar task at \(Date())")
        let contentsOfCellarFolder = await getContentsOfFolder(targetFolder: AppConstantsLocal.brewCellarPath)

        brewData.installedFormulae = [] // Empty the tracker in case there is already something in it

        for package in contentsOfCellarFolder
        {
            brewData.installedFormulae.append(package)
            // print("Appended \(package)")
        }

        // print(brewData.installedFormulae!)
    }

    Task
    { // Task that gets the contents of the Cask folder
        print("Started Cask task at \(Date())")
        let contentsOfCaskFolder = await getContentsOfFolder(targetFolder: AppConstantsLocal.brewCaskPath)

        brewData.installedCasks = [] // Empty the tracker in case there is already something in it

        for package in contentsOfCaskFolder
        {
            brewData.installedCasks.append(package)
            // print("Appended \(package)")
        }

        // print(brewData.installedCasks!)
    }
}
