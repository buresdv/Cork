//
//  Brew Packages Tracker.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation
import SwiftUI
import Defaults

@Observable @MainActor
class BrewPackagesTracker
{
    var installedFormulae: BrewPackages = .init()
    var installedCasks: BrewPackages = .init()

    // MARK: - Successfully loaded packages
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
    
    /// Formulae than can be displayed, depending on whether the user set only to display intentionally installed packages
    var displayableSuccessfullyLoadedFormulae: Set<BrewPackage>
    {
        let displayOnlyIntentionallyInstalledPackagesByDefault: Bool = Defaults[.displayOnlyIntentionallyInstalledPackagesByDefault]
        
        if displayOnlyIntentionallyInstalledPackagesByDefault
        {
            return self.successfullyLoadedFormulae.filter(\.installedIntentionally)
        }
        else
        {
            return self.successfullyLoadedFormulae
        }
    }
    
    /// Collected errors from failed Formulae loading
    var unsuccessfullyLoadedFormulaeErrors: [PackageLoadingError]
    {
        return installedFormulae.compactMap
       { rawResult in
            if case .failure(let failure) = rawResult {
                return failure
            }
            else
            {
                return nil
            }
        }
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
    
    var displayableSuccessfullyLoadedCasks: Set<BrewPackage>
    {
        let displayOnlyIntentionallyInstalledPackagesByDefault: Bool = Defaults[.displayOnlyIntentionallyInstalledPackagesByDefault]
        
        if displayOnlyIntentionallyInstalledPackagesByDefault
        {
            return self.successfullyLoadedCasks.filter(\.installedIntentionally)
        }
        else
        {
            return self.successfullyLoadedCasks
        }
    }
    
    /// Collected errors from failed Casks loading
    var unsuccessfullyLoadedCasksErrors: [PackageLoadingError]
    {
        return installedCasks.compactMap
        { rawResult in
            if case .failure(let failure) = rawResult {
                return failure
            }
            else
            {
                return nil
            }
        }
    }
    
    // MARK: - Functions
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
    
    var adoptableApps: [AdoptableApp] = .init()
    
    var adoptableAppsSelectedToBeAdopted: [AdoptableApp]
    {
        return self.adoptableApps.filter(\.isMarkedForAdoption)
    }
    
    var hasSelectedOnlySomeAppsToAdopt: Bool
    {
        if adoptableApps.count != adoptableAppsSelectedToBeAdopted.count
        {
            return true
        }
        else
        {
            return false
        }
    }
}

extension BrewPackagesTracker
{
    
    var numberOfInstalledFormulae: Int
    {
        return self.displayableSuccessfullyLoadedFormulae.count
    }
    
    var numberOfInstalledCasks: Int
    {
        return self.displayableSuccessfullyLoadedCasks.count
    }
    
    var numberOfInstalledPackages: Int
    {
        return self.numberOfInstalledFormulae + self.numberOfInstalledCasks
    }
}
