//
//  Assign Types to Cached Packages.swift
//  Cork
//
//  Created by David Bureš - P on 16.01.2025.
//

import CorkShared
import Foundation

public extension CachedDownloadsTracker
{
    func assignPackageTypeToCachedDownloads(
        cachedDownloads: [CachedDownload],
        brewPackagesTracker: BrewPackagesTracker
    ) -> [CachedDownload]
    {
        AppConstants.shared.logger.debug("Package tracker in cached download assignment function has \(brewPackagesTracker.installedFormulae.count + brewPackagesTracker.installedCasks.count) packages")

        return cachedDownloads.map
        { cachedDownload in
            // So the package doesn§t get assigned twice
            guard cachedDownload.packageType != .other
            else
            {
                return cachedDownload
            }

            let normalizedCachedPackageName: String = cachedDownload.packageName.onlyLetters

            if brewPackagesTracker.successfullyLoadedFormulae.contains(where: {
                let packageName = $0.name(withPrecision: .general)
                return packageName.localizedCaseInsensitiveContains(normalizedCachedPackageName)
                    || normalizedCachedPackageName.localizedCaseInsensitiveContains(packageName)
            }) { /// The cached package is a formula
                AppConstants.shared.logger.debug("Cached package \(cachedDownload.packageName) (\(normalizedCachedPackageName)) is a formula")
                return .init(packageName: cachedDownload.packageName, sizeInBytes: cachedDownload.sizeInBytes, packageType: .formula)
            }
            else if brewPackagesTracker.successfullyLoadedCasks.contains(where: {
                let packageName = $0.name(withPrecision: .general)
                return packageName.localizedCaseInsensitiveContains(normalizedCachedPackageName)
                    || normalizedCachedPackageName.localizedCaseInsensitiveContains(packageName)
            }) { /// The cached package is a cask
                AppConstants.shared.logger.debug("Cached package \(cachedDownload.packageName) (\(normalizedCachedPackageName)) is a cask")
                return .init(packageName: cachedDownload.packageName, sizeInBytes: cachedDownload.sizeInBytes, packageType: .cask)
            }
            else
            {
                AppConstants.shared.logger.debug("Cached package \(cachedDownload.packageName) (\(normalizedCachedPackageName)) is unknown")
                return .init(packageName: cachedDownload.packageName, sizeInBytes: cachedDownload.sizeInBytes, packageType: .unknown)
            }
        }
    }
}
