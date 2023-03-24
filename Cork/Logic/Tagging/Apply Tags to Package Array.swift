//
//  Apply Tags to Package Array.swift
//  Cork
//
//  Created by David Bureš on 21.03.2023.
//

import Foundation

@MainActor
func applyTagsToPackageTrackingArray(appState: AppState, brewData: BrewDataStorage) async throws -> Void
{
    for taggedName in appState.taggedPackageNames
    {
        print("Will attempt to place package name \(taggedName)")
        if let formulaIndexToReplace = brewData.installedFormulae.firstIndex(where: { $0.name == taggedName })
        {
            print("Formula index to replace: \(formulaIndexToReplace)")
            
            let oldFormula = brewData.installedFormulae[formulaIndexToReplace]
            
            brewData.installedFormulae[formulaIndexToReplace] = BrewPackage(id: oldFormula.id, name: oldFormula.name, isCask: oldFormula.isCask, isTagged: true, installedOn: oldFormula.installedOn, versions: oldFormula.versions, url: oldFormula.url, sizeInBytes: oldFormula.sizeInBytes)
        }
        else
        {
            print("\(taggedName) not found in Formulae")
        }
        
        if let caskIndexToReplace = brewData.installedCasks.firstIndex(where: { $0.name == taggedName })
        {
            print("Cask index to replace: \(caskIndexToReplace)")
            
            let oldCask = brewData.installedCasks[caskIndexToReplace]
            
            brewData.installedCasks[caskIndexToReplace] = BrewPackage(id: oldCask.id, name: oldCask.name, isCask: oldCask.isCask, isTagged: true, installedOn: oldCask.installedOn, versions: oldCask.versions, url: oldCask.url, sizeInBytes: oldCask.sizeInBytes)
        }
        else
        {
            print("\(taggedName) not found in Casks")
        }
    }
    
}
