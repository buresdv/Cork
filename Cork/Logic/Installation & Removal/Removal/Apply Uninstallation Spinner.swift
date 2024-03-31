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
    AppConstants.logger.debug("""
Brew data: 
   Installed Formulae: \(brewData.installedFormulae)
   Installed Casks: \(brewData.installedCasks)
""")
    AppConstants.logger.debug("Will try to apply uninstallation spinner to package \(package.name)")
    
    if !package.isCask
    {
        brewData.installedFormulae = Set(brewData.installedFormulae.map({ formula in
            var copyFormula = formula
            if copyFormula.name == package.name
            {
                copyFormula.changeBeingModifiedStatus()
            }
            return copyFormula
        }))
    }
    else
    {
        brewData.installedFormulae = Set(brewData.installedCasks.map({ cask in
            var copyCask = cask
            if copyCask.name == package.name
            {
                copyCask.changeBeingModifiedStatus()
            }
            return copyCask
        }))
    }
}
