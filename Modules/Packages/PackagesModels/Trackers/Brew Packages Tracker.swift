//
//  Brew Packages Tracker.swift
//  Cork
//
//  Created by David Bureš - P on 28.10.2025.
//

import Foundation
import SwiftUI
import Defaults
import SwiftData
import FactoryKit
import CorkShared

@Observable @MainActor
public class BrewPackagesTracker
{
    @ObservationIgnored @Injected(\.appConstants) private var appConstants: AppConstants
    
    public nonisolated init() {}
    
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
    
    // MARK: - App adoption
    /// All adoptable apps, including those that are excluded
    public var adoptableApps: [AdoptableApp] = .init()
    
    public var excludedAdoptableApps: [AdoptableApp]
    {
        return adoptableApps.filter { adoptableApp in
            excludedAdoptableAppsInSavedFormat.contains(where: { $0.appExecutable == adoptableApp.appExecutable })
        }
        .sorted(by: { $0.appExecutable < $1.appExecutable })
    }
    
    private static let excludedAdoptableAppsFetchDescriptor: FetchDescriptor<ExcludedAdoptableApp> = .init(predicate: #Predicate { _ in
        return true
    })
    
    /// Saved excluded adoptable apps
    private var excludedAdoptableAppsInSavedFormat: [ExcludedAdoptableApp]
    {
        do
        {
            let fetchedExcludedPackages = try appConstants.modelContainer.mainContext.fetch(BrewPackagesTracker.excludedAdoptableAppsFetchDescriptor)
            
            return fetchedExcludedPackages
        }
        catch let excludedPackagesFetchingError
        {
            appConstants.logger.error("Failed to fetch adoptable apps from database inside BrewPackagesTracker!: \(excludedPackagesFetchingError)")
            
            return .init()
        }
    }
    
    /// Adoptable apps, minus those that are excluded
    public var adoptableAppsNonExcluded: [AdoptableApp]
    {
        return adoptableApps.filter { adoptableApp in
            return !excludedAdoptableAppsInSavedFormat.contains(where: { $0.appExecutable == adoptableApp.appExecutable })
        }
        .sorted(by: { $0.appExecutable < $1.appExecutable })
    }
    
    /// Adoptable apps that will get installed when clicking the `Adopt` button
    public var adoptableAppsSelectedToBeAdopted: [AdoptableApp]
    {
        return self.adoptableAppsNonExcluded.filter(\.isMarkedForAdoption)
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

public extension BrewPackagesTracker
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
