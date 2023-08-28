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
        if let indexToReplace = brewData.installedFormulae.firstIndex(where: { $0.name == package.name })
        {
            brewData.installedFormulae[indexToReplace].changeTaggedStatus()
        }
        
    }
    else
    {
        if let indextoReplace = brewData.installedCasks.firstIndex(where: { $0.name == package.name })
        {
            brewData.installedCasks[indextoReplace].changeTaggedStatus()
        }
    }
    
    appState.taggedPackageNames.insert(package.name)
    
    print("Tagged package with ID \(package)")
    
    print("Tagged packages: \(appState.taggedPackageNames)")
}
