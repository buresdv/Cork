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
            
            brewData.installedFormulae[formulaIndexToReplace].changeTaggedStatus()
        }
        else
        {
            print("\(taggedName) not found in Formulae")
        }
        
        if let caskIndexToReplace = brewData.installedCasks.firstIndex(where: { $0.name == taggedName })
        {
            print("Cask index to replace: \(caskIndexToReplace)")
            
            brewData.installedCasks[caskIndexToReplace].changeTaggedStatus()
        }
        else
        {
            print("\(taggedName) not found in Casks")
        }
    }
    
}
