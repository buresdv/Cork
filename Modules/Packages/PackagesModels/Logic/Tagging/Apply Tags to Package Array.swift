//
//  Apply Tags to Package Array.swift
//  Cork
//
//  Created by David Bureš on 21.03.2023.
//

import Foundation
import CorkShared
import SwiftData

extension BrewPackagesTracker
{
    enum TaggedPackageNameRetrievalError: LocalizedError
    {
        case couldNotFetchPackageNamesFromDatabase
        
        var errorDescription: String
        {
            switch self {
            case .couldNotFetchPackageNamesFromDatabase:
                return "error.tagged-package-loading.coult-not-fetch-package-names-from-database.description"
            }
        }
    }
    
    /// Get the names of the tagged packages from the SwiftData database
    func getNamesOfTaggedPackages() async throws(TaggedPackageNameRetrievalError) -> Set<String>
    {
        let storageContext: ModelContext = AppConstants.shared.modelContainer.mainContext
        
        let taggedPackageFetcher: FetchDescriptor = FetchDescriptor<SavedTaggedPackage>(
            predicate: #Predicate { _ in
                return true
            }
        )
        
        /// Try to fetch the saved tagged packages, and stop execution if there are none
        guard let loadedTaggedPackages = try? storageContext.fetch(taggedPackageFetcher) else
        {
            AppConstants.shared.logger.log("Failed to load tagged packages")
            throw .couldNotFetchPackageNamesFromDatabase
        }
        
        guard !loadedTaggedPackages.isEmpty else
        {
            AppConstants.shared.logger.log("There are no tagged packages to apply the tagged status to")
 
            return .init()
        }
        
        let namesOfTaggedPackages: [String] = loadedTaggedPackages.map({ $0.fullName })
        
        AppConstants.shared.logger.debug("Loaded tagged packages: \(namesOfTaggedPackages)")
        
        /// Change the custom saveable object into strings
        return Set(namesOfTaggedPackages)
    }
    
    /// Load tagged package from storage, and apply them to the relevant packages
    @MainActor
    func applyTags() async throws(TaggedPackageNameRetrievalError)
    {
        do
        {
            let taggedPackagesFullNames: Set<String> = try await getNamesOfTaggedPackages()
            
            for taggedName in taggedPackagesFullNames
            {
                AppConstants.shared.logger.log("Will attempt to place package name \(taggedName, privacy: .public)")
                self.installedFormulae = Set(self.installedFormulae.map
                { formula in
                    switch formula
                    {
                    case .success(var brewPackage):
                        if brewPackage.getPackageName(withPrecision: .precise) == taggedName
                        {
                            brewPackage.changeTaggedStatus(purpose: .justLoading)
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
                        if brewPackage.getPackageName(withPrecision: .precise) == taggedName
                        {
                            brewPackage.changeTaggedStatus(purpose: .justLoading)
                        }
                        return .success(brewPackage)
                    case .failure(let error):
                        return .failure(error)
                    }
                })
            }
        }
        catch let taggedPackageLoadingError
        {
            throw taggedPackageLoadingError
        }
    }
}
