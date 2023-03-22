//
//  Untag Package.swift
//  Cork
//
//  Created by David Bureš on 21.03.2023.
//

import Foundation

@MainActor
func untagPackage(package: BrewPackage, brewData: BrewDataStorage, appState: AppState) async -> Void
{
    if !package.isCask
    {
        if let indexToReplace = brewData.installedFormulae.firstIndex(where: { $0.name == package.name })
        {
            brewData.installedFormulae[indexToReplace] = BrewPackage(id: package.id, name: package.name, isCask: package.isCask, isTagged: false, installedOn: package.installedOn, versions: package.versions, sizeInBytes: package.sizeInBytes)
        }
        
    }
    else
    {
        if let indextoReplace = brewData.installedCasks.firstIndex(where: { $0.name == package.name })
        {
            brewData.installedCasks[indextoReplace] = BrewPackage(id: package.id, name: package.name, isCask: package.isCask, isTagged: false, installedOn: package.installedOn, versions: package.versions, sizeInBytes: package.sizeInBytes)
        }
    }
    
    if let indexOfPackageToRemove = appState.taggedPackageNames.firstIndex(of: package.name)
    {
        appState.taggedPackageNames.remove(at: indexOfPackageToRemove)
    }
    
    print("Tagged packages: \(appState.taggedPackageNames) (\(appState.taggedPackageNames.count))")
    
}
