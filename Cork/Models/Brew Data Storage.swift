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
    @Published var installedFormulae: BrewPackages = .init()
    @Published var installedCasks: BrewPackages = .init()

    /// Formulae that were successfuly loaded from disk
    var successfullyLoadedFormulae: Set<BrewPackage>
    {
        return Set(installedFormulae.compactMap
        { rawResult in
            if case .success(let success) = rawResult
            {
                return success
            }
            else
            {
                return nil
            }
        })
    }

    /// Casks that were successfuly loaded from disk
    var successfullyLoadedCasks: Set<BrewPackage>
    {
        return Set(installedCasks.compactMap
        { rawResult in
            if case .success(let success) = rawResult
            {
                return success
            }
            else
            {
                return nil
            }
        })
    }

    func insertPackageIntoTracker(_ package: BrewPackage)
    {
        if package.type == .formula
        {
            installedFormulae.insert(.success(package))
        }
        else
        {
            installedCasks.insert(.success(package))
        }
    }

    /*
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
        switch tracker
        {
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
     */
}

@MainActor
class AvailableTaps: ObservableObject
{
    @Published var addedTaps: [BrewTap] = .init()
}
