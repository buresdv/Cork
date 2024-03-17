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
        AppConstants.logger.log("Will attempt to place package name \(taggedName, privacy: .public)")
        brewData.installedFormulae = Set(brewData.installedFormulae.map({ formula in
            var copyFormula = formula
            if copyFormula.name == taggedName
            {
                copyFormula.changeTaggedStatus()
            }
            return copyFormula
        }))

        brewData.installedCasks = Set(brewData.installedCasks.map({ cask in
            var copyCask = cask
            if copyCask.name == taggedName
            {
                copyCask.changeTaggedStatus()
            }
            return copyCask
        }))
    }
    
}
