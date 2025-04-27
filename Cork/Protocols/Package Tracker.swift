//
//  Package Tracker.swift
//  Cork
//
//  Created by David Bureš - P on 27.04.2025.
//

import Foundation
import CorkShared

/// Implement features for package tracking
protocol PackageTrackable: ObservableObject, Sendable
{
    func processRawPackageArray(trackingArray: [BrewPackage]) async -> [BrewPackage]
}

extension PackageTrackable
{
    
    /// Processes the raw array
    /// The result is an array where different versions of the same package have been consolidated into a single element of the array with multiple versions assigned to it, instead of an array where different versions of a package are different entires in the array
    func processRawPackageArray(trackingArray: [BrewPackage]) async -> [BrewPackage]
    {
        /// Temporary array where processed found search results will be put
        var tempArray: [BrewPackage] = .init()
        
        /// Let's loop over the unprocessed array to find duplicate packages
        for unprocessedFoundPackage in trackingArray
        {
            AppConstants.shared.logger.debug("Will try to process raw package name \(unprocessedFoundPackage.name)")
            
            let splitPackageNameAndVersion: (packageName: String, homebrewVersion: String?) = unprocessedFoundPackage.name.splitPackageNameFromHomebrewVersion()
            
            // Let's check if there's a version defined for this package. Is there isn't, just append the name of the package itself, because this means it doesn't have any specific versions defined.
            guard let packageHomebrewVersion = splitPackageNameAndVersion.homebrewVersion else
            {
                AppConstants.shared.logger.debug("Package name \(unprocessedFoundPackage.name) doesn't have a \"@\" character. Will place it directly into the tracker")
                
                tempArray.append(unprocessedFoundPackage)
                
                continue
            }
            
            AppConstants.shared.logger.debug("Package name \(unprocessedFoundPackage.name) has a \"@\" character. Will process it")
            
            /// Let's see if there already is an identical package - We do this by finding the first index of a package inside the temporary array whose name matches this unprocessed package
            /// If it matches, it is already in the tracker, and we just need to add another version to it
            if let indexOfPreviouslyProcessedPackage = tempArray.firstIndex(where: { $0.name == splitPackageNameAndVersion.packageName })
            {
                tempArray[indexOfPreviouslyProcessedPackage].versions.append(packageHomebrewVersion)
            }
            else
            { /// If it doesn't match, it's not in the array yet. Let's add it to the array
                tempArray.append(
                    .init(name: splitPackageNameAndVersion.packageName, type: unprocessedFoundPackage.type, installedOn: nil, versions: [packageHomebrewVersion], sizeInBytes: nil, downloadCount: nil)
                )
            }
        }
        
        return tempArray
    }
}
