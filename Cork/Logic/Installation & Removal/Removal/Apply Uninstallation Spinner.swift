//
//  Apply Uninstallation Spinner.swift
//  Cork
//
//  Created by David Bureš on 02.09.2023.
//

import Foundation

@MainActor
func applyUninstallationSpinner(to package: BrewPackage, brewData: BrewDataStorage) -> Void
{
    print("Brew data: \(brewData)")
    print("Will try to apply uninstallation spinner to package \(package)")
    
    if !package.isCask
    {
        if let indexToReplace = brewData.installedFormulae.firstIndex(where: { $0.name == package.name })
        {
            print("Found formula at index \(indexToReplace)")
            brewData.installedFormulae[indexToReplace].changeBeingModifiedStatus()
        }
        
    }
    else
    {
        if let indextoReplace = brewData.installedCasks.firstIndex(where: { $0.name == package.name })
        {
            print("Found cask at index \(indextoReplace)")
            brewData.installedCasks[indextoReplace].changeBeingModifiedStatus()
        }
    }
}
