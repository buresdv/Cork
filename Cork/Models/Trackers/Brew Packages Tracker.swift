//
//  Brew Packages Tracker.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation
import SwiftUI

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
}

extension BrewPackagesTracker
{
    var numberOfInstalledFormulae: Int
    {
        let displayOnlyIntentionallyInstalledPackagesByDefault: Bool = UserDefaults.standard.bool(forKey: "displayOnlyIntentionallyInstalledPackagesByDefault")
        
        if displayOnlyIntentionallyInstalledPackagesByDefault
        {
            return self.successfullyLoadedFormulae.filter(\.installedIntentionally).count
        }
        else
        {
            return self.successfullyLoadedFormulae.count
        }
    }
    
    var numberOfInstalledCasks: Int
    {
        return self.successfullyLoadedCasks.count
    }
    
    var numberOfInstalledPackages: Int
    {
        return self.numberOfInstalledFormulae + self.numberOfInstalledCasks
    }
}
