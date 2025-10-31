//
//  Brew Packages Tracker.swift
//  Cork
//
//  Created by David Bureš - P on 28.10.2025.
//

import Foundation
import SwiftUI
import Defaults

@Observable @MainActor
public class BrewPackagesTracker
{
    public init() {}
    
    public var installedFormulae: BrewPackages = .init()
    public var installedCasks: BrewPackages = .init()

    // MARK: - Successfully loaded packages
    /// Formulae that were successfuly loaded from disk
    public var successfullyLoadedFormulae: Set<BrewPackage>
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
    public var displayableSuccessfullyLoadedFormulae: Set<BrewPackage>
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
    public var unsuccessfullyLoadedFormulaeErrors: [BrewPackage.PackageLoadingError]
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
    public var successfullyLoadedCasks: Set<BrewPackage>
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
    
    public var displayableSuccessfullyLoadedCasks: Set<BrewPackage>
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
    public var unsuccessfullyLoadedCasksErrors: [BrewPackage.PackageLoadingError]
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
    public func insertPackageIntoTracker(_ package: BrewPackage)
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
    
    public var adoptableApps: [AdoptableApp] = .init()
    
    public var adoptableAppsSelectedToBeAdopted: [AdoptableApp]
    {
        return self.adoptableApps.filter(\.isMarkedForAdoption)
    }
    
    public var hasSelectedOnlySomeAppsToAdopt: Bool
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
