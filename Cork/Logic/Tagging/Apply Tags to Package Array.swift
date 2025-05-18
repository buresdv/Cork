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
    /// Load tagged package from storage, and apply them to the relevant packages
    @MainActor
    func applyTags() async throws
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
            return
        }
        
        guard !loadedTaggedPackages.isEmpty else
        {
            AppConstants.shared.logger.log("There are no tagged packages to apply the tagged status to")
            return
        }
        
        /// Change the custom saveable object into strings
        let taggedPackagesFullNames: [String] = loadedTaggedPackages.map({ $0.fullName })
        
        for taggedName in taggedPackagesFullNames
        {
            AppConstants.shared.logger.log("Will attempt to place package name \(taggedName, privacy: .public)")
            self.installedFormulae = Set(self.installedFormulae.map
            { formula in
                switch formula
                {
                case .success(var brewPackage):
                    if brewPackage.name == taggedName
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
                    if brewPackage.name == taggedName
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
}
