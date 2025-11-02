//
//  Update Package Tracker In place.swift
//  Cork
//
//  Created by David Bureš on 03.01.2025.
//

import Foundation
import CorkModels

extension BrewPackagesTracker
{
    /// Update a ``BrewPackage``'s property in-place
    /// Used to update the UI when a property on ``BrewPackage`` changes
    @MainActor
    func updatePackageInPlace(_ package: BrewPackage, modification: (inout BrewPackage) -> Void)
    {
        if package.type == .formula
        {
            var updatedFormulae: BrewPackages = installedFormulae
            if let index = updatedFormulae.firstIndex(where: {
                if case .success(let packageCopy) = $0
                {
                    return packageCopy.id == package.id
                }
                return false
            })
            {
                var updatedPackage: BrewPackage = package
                modification(&updatedPackage)
                updatedFormulae.remove(at: index)
                updatedFormulae.insert(.success(updatedPackage))
                installedFormulae = updatedFormulae
            }
        }
        else
        {
            var updatedCasks: BrewPackages = installedCasks
            if let index = updatedCasks.firstIndex(where: {
                if case .success(let packageCopy) = $0
                {
                    return packageCopy.id == package.id
                }
                return false
            })
            {
                var updatedPackage: BrewPackage = package
                modification(&updatedPackage)
                updatedCasks.remove(at: index)
                updatedCasks.insert(.success(updatedPackage))
                installedCasks = updatedCasks
            }
        }
    }
}
