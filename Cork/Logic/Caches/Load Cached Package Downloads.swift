//
//  Load Cached Package Downloads.swift
//  Cork
//
//  Created by David Bureš - P on 16.01.2025.
//

import Foundation
import CorkShared

extension CachedDownloadsTracker
{
    /// Load cached downloads and assign their types
    @MainActor
    func loadCachedDownloadedPackages(brewPackagesTracker: BrewPackagesTracker) async
    {
        AppConstants.shared.logger.info("Will load cached downloaded packages")
        
        self.cachedDownloads = .init()
        
        let smallestDispalyableSize: Int = .init(AppConstants.shared.brewCachedDownloadsPath.directorySize / 50)

        var packagesThatAreTooSmallToDisplaySize: Int = 0

        guard let cachedDownloadsFolderContents: [URL] = try? FileManager.default.contentsOfDirectory(at: AppConstants.shared.brewCachedDownloadsPath, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles])
        else
        {
            return
        }

        let usableCachedDownloads: [URL] = cachedDownloadsFolderContents.filter { $0.pathExtension != "json" }

        for usableCachedDownload in usableCachedDownloads
        {
            guard var itemName: String = try? usableCachedDownload.lastPathComponent.regexMatch("(?<=--)(.*?)(?=\\.)")
            else
            {
                return
            }

            AppConstants.shared.logger.debug("Temp item name: \(itemName, privacy: .public)")

            if itemName.contains("--")
            {
                do
                {
                    itemName = try itemName.regexMatch(".*?(?=--)")
                }
                catch {}
            }

            guard let itemAttributes = try? FileManager.default.attributesOfItem(atPath: usableCachedDownload.path)
            else
            {
                return
            }

            guard let itemSize = itemAttributes[.size] as? Int
            else
            {
                return
            }

            if itemSize < smallestDispalyableSize
            {
                packagesThatAreTooSmallToDisplaySize = packagesThatAreTooSmallToDisplaySize + itemSize
            }
            else
            {
                cachedDownloads.append(CachedDownload(packageName: itemName, sizeInBytes: itemSize))
            }

            AppConstants.shared.logger.debug("Others size: \(packagesThatAreTooSmallToDisplaySize, privacy: .public)")
        }

        cachedDownloads = cachedDownloads.sorted(by: { $0.sizeInBytes < $1.sizeInBytes })

        cachedDownloads.append(.init(packageName: String(localized: "start-page.cached-downloads.graph.other-smaller-packages"), sizeInBytes: packagesThatAreTooSmallToDisplaySize, packageType: .other))
        
        self.assignPackageTypeToCachedDownloads(brewPackagesTracker: brewPackagesTracker)
    }
}
