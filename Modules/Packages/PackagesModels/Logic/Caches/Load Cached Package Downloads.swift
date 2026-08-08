//
//  Load Cached Package Downloads.swift
//  Cork
//
//  Created by David Bureš - P on 16.01.2025.
//

import CorkShared
import Foundation

public extension CachedDownloadsTracker
{
    /// Load cached downloads and assign their types
    @MainActor
    func loadCachedDownloadedPackages(brewPackagesTracker: BrewPackagesTracker) async
    {
        AppConstants.shared.logger.info("Will load cached downloaded packages")
        
        let currentSizeOfCachedPackageFolder: Int64 = appConstants.brewCachedDownloadsPath.directorySize

        AppConstants.shared.logger.info("Last size: \(self.lastSizeOfCachedPackageFolder), new size: \(currentSizeOfCachedPackageFolder)")

        guard self.lastSizeOfCachedPackageFolder != currentSizeOfCachedPackageFolder
        else
        {
            AppConstants.shared.logger.info("Size of cached downloads has not changed, no need to reload.")
            return
        }

        AppConstants.shared.logger.info("Size of cached downloads has changed. Will reload.")

        guard let cachedDownloadsFolderContents: [URL] = try? FileManager.default.contentsOfDirectory(
            at: AppConstants.shared.brewCachedDownloadsPath,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )
        else
        {
            self.cachedDownloads = .init()
            
            self.lastSizeOfCachedPackageFolder = currentSizeOfCachedPackageFolder
            
            return
        }

        let usableCachedDownloads: [URL] = cachedDownloadsFolderContents.filter { $0.pathExtension != "json" }
        
        let smallestDisplayableSize: Int = .init(currentSizeOfCachedPackageFolder / 50)
        
        var packagesThatAreTooSmallToDisplaySize: Int = 0
        
        var consolidatedCachedDownloads: [CachedDownload] = .init()

        for usableCachedDownload in usableCachedDownloads
        {
            guard var itemName: String = try? usableCachedDownload.lastPathComponent.regexMatch("(?<=--)(.*?)(?=\\.)") else
            {
                continue
            }

            if itemName.contains("--")
            {
                if let strippedName = try? itemName.regexMatch(".*?(?=--)")
                {
                    itemName = strippedName
                }
            }

            guard let itemAttributes = try? FileManager.default.attributesOfItem(atPath: usableCachedDownload.path),
                  let itemSize = itemAttributes[.size] as? Int else
            {
                continue
            }

            if itemSize < smallestDisplayableSize
            {
                packagesThatAreTooSmallToDisplaySize += itemSize
            }
            else
            {
                consolidatedCachedDownloads.append(.init(packageName: itemName, sizeInBytes: itemSize))
            }
        }

        consolidatedCachedDownloads.sort(by: { $0.sizeInBytes < $1.sizeInBytes })

        if packagesThatAreTooSmallToDisplaySize > 0
        {
            consolidatedCachedDownloads.append(.init(
                packageName: String(localized: "start-page.cached-downloads.graph.other-smaller-packages"),
                sizeInBytes: packagesThatAreTooSmallToDisplaySize,
                packageType: .other
            ))
        }

        let cachedDownloadsWithTheirTypesAssigned = assignPackageTypeToCachedDownloads(
            cachedDownloads: consolidatedCachedDownloads,
            brewPackagesTracker: brewPackagesTracker
        )

        self.cachedDownloads = cachedDownloadsWithTheirTypesAssigned
        
        self.lastSizeOfCachedPackageFolder = currentSizeOfCachedPackageFolder

        AppConstants.shared.logger.info("Finished reload. Cached downloads count: \(cachedDownloadsWithTheirTypesAssigned.count)")
    }
}
