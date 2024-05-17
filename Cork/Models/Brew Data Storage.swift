//
//  Brew Data Storage.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation
import SwiftUI

@MainActor
class BrewDataStorage: ObservableObject
{
    @Published var installedFormulae: Set<BrewPackage> = .init()
    @Published var installedCasks: Set<BrewPackage> = .init()

    func insertPackageIntoTracker(_ package: BrewPackage)
    {
        if !package.isCask
        {
            installedFormulae.insert(package)
        }
        else
        {
            installedCasks.insert(package)
        }
    }

    func removeFormulaFromTracker(withName name: String)
    {
        removePackageFromTracker(withName: name, tracker: .formula)
    }
    func removeCaskFromTracker(withName name: String)
    {
        removePackageFromTracker(withName: name, tracker: .cask)
    }

    private func removePackageFromTracker(withName name: String, tracker: PackageType)
    {
        switch tracker {
            case .formula:
                if let index = installedFormulae.firstIndex(where: { $0.name == name })
                {
                    installedFormulae.remove(at: index)
                }
            case .cask:
                if let index = installedCasks.firstIndex(where: { $0.name == name })
                {
                    installedCasks.remove(at: index)
                }
        }
    }
}

@MainActor
class AvailableTaps: ObservableObject
{
    @Published var addedTaps: [BrewTap] = .init()
}
