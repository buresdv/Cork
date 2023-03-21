//
//  Untag Package.swift
//  Cork
//
//  Created by David Bureš on 21.03.2023.
//

import Foundation

@MainActor
func untagPackage(package: BrewPackage, brewData: BrewDataStorage) async -> Void
{
    if !package.isCask
    {
        if let indexToReplace = brewData.installedFormulae.firstIndex(where: { $0.id == package.id })
        {
            brewData.installedFormulae[indexToReplace] = BrewPackage(name: package.name, isCask: package.isCask, isTagged: false, installedOn: package.installedOn, versions: package.versions, sizeInBytes: package.sizeInBytes)
        }
        
    }
    else
    {
        if let indextoReplace = brewData.installedCasks.firstIndex(where: { $0.id == package.id })
        {
            brewData.installedCasks[indextoReplace] = BrewPackage(name: package.name, isCask: package.isCask, isTagged: false, installedOn: package.installedOn, versions: package.versions, sizeInBytes: package.sizeInBytes)
        }
    }
}
