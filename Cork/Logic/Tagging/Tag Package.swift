//
//  Tag Package.swift
//  Cork
//
//  Created by David Bureš on 21.03.2023.
//

import Foundation

@MainActor
func tagPackage(package: BrewPackage, brewData: BrewDataStorage, appState: AppState) async -> Void
{
    if !package.isCask
    {
        if let indexToReplace = brewData.installedFormulae.firstIndex(where: { $0.id == package.id })
        {
            brewData.installedFormulae[indexToReplace] = BrewPackage(id: package.id, name: package.name, isCask: package.isCask, isTagged: true, installedOn: package.installedOn, versions: package.versions, sizeInBytes: package.sizeInBytes)
        }
        
    }
    else
    {
        if let indextoReplace = brewData.installedCasks.firstIndex(where: { $0.id == package.id })
        {
            brewData.installedCasks[indextoReplace] = BrewPackage(id: package.id, name: package.name, isCask: package.isCask, isTagged: true, installedOn: package.installedOn, versions: package.versions, sizeInBytes: package.sizeInBytes)
        }
    }
    
    appState.taggedPackageIDs.insert(package.id)
    
    print("Tagged package with ID \(package)")
    
    print("Tagged packages: \(appState.taggedPackageIDs)")
}
