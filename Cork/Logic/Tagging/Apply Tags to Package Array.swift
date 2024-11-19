//
//  Apply Tags to Package Array.swift
//  Cork
//
//  Created by David Bureš on 21.03.2023.
//

import Foundation
import CorkShared

extension BrewDataStorage
{
    @MainActor
    func applyTags(appState: AppState) async throws
    {
        for taggedName in appState.taggedPackageNames
        {
            AppConstants.shared.logger.log("Will attempt to place package name \(taggedName, privacy: .public)")
            self.installedFormulae = Set(self.installedFormulae.map
            { formula in
                switch formula
                {
                case .success(var brewPackage):
                    if brewPackage.name == taggedName
                    {
                        brewPackage.changeTaggedStatus()
                    }
                    return .success(brewPackage)
                case .failure(let error):
                    return .failure(error)
                }
            })

            self.installedCasks = Set(self.installedCasks.map
            { cask in
                switch cask
                {
                case .success(var brewPackage):
                    if brewPackage.name == taggedName
                    {
                        brewPackage.changeTaggedStatus()
                    }
                    return .success(brewPackage)
                case .failure(let error):
                    return .failure(error)
                }
            })
        }
    }
}
