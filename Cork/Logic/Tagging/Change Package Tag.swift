//
//  Tag Package.swift
//  Cork
//
//  Created by David Bureš on 21.03.2023.
//

import Foundation
import CorkShared

/*
@MainActor
func changePackageTagStatus(package: BrewPackage, brewData: BrewDataStorage, appState: AppState) async
{
    if package.type == .formula
    {
        brewData.installedFormulae = Set(brewData.installedFormulae.map
        { formula in
            switch formula
            {
            case .success(let brewPackage):
                if brewPackage.name == package.name
                {
                    brewPackage.changeTaggedStatus()
                }
                return brewPackage
            case .failure(let error):
                return .failure(error)
            }
            var copyFormula: BrewPackage = formula
            if copyFormula.name == package.name
            {
                copyFormula.changeTaggedStatus()
            }
            return copyFormula
        })
    }
    else
    {
        brewData.installedFormulae = Set(brewData.installedCasks.map
        { cask in
            var copyCask: BrewPackage = cask
            if copyCask.name == package.name
            {
                copyCask.changeTaggedStatus()
            }
            return copyCask
        })
    }

    if appState.taggedPackageNames.contains(package.name)
    {
        appState.taggedPackageNames.remove(package.name)
    }
    else
    {
        appState.taggedPackageNames.insert(package.name)
    }

    AppConstants.shared.logger.debug("Tagged package with ID \(package.id, privacy: .public): \(package.name, privacy: .public)")

    AppConstants.shared.logger.debug("Tagged packages: \(appState.taggedPackageNames, privacy: .public)")
}
*/
