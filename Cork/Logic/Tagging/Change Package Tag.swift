//
//  Tag Package.swift
//  Cork
//
//  Created by David Bureš on 21.03.2023.
//

import Foundation

@MainActor
func changePackageTagStatus(package: BrewPackage, brewData: BrewDataStorage, appState: AppState) async -> Void
{
    if !package.isCask
    {
        brewData.installedFormulae = Set(brewData.installedFormulae.map({ formula in
            var copyFormula = formula
            if copyFormula.name == package.name
            {
                copyFormula.changeTaggedStatus()
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
                copyCask.changeTaggedStatus()
            }
            return copyCask
        }))
    }

    if appState.taggedPackageNames.contains(package.name)
    {
        appState.taggedPackageNames.remove(package.name)
    }
    else
    {
        appState.taggedPackageNames.insert(package.name)
    }

    print("Tagged package with ID \(package)")
    
    print("Tagged packages: \(appState.taggedPackageNames)")
}
