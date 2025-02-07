//
//  Get Contents of Folder.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation
import SwiftUI
import CorkShared

/*
func getContentsOfFolder(targetFolder: URL) async throws -> Set<BrewPackage>
{
    do
    {
        guard let items = targetFolder.validPackageURLs
        else
        {
            throw PackageLoadingError.failedWhileLoadingPackages(failureReason: String(localized: "alert.fatal.could-not-filter-invalid-packages"))
        }

        let loadedPackages: Set<BrewPackage> = try await withThrowingTaskGroup(of: BrewPackage.self, returning: Set<BrewPackage>.self)
        { taskGroup in
            for item in items
            {
                let fullURLToPackageFolderCurrentlyBeingProcessed: URL = targetFolder.appendingPathComponent(item, conformingTo: .folder)

                taskGroup.addTask(priority: .high)
                {
                    guard let versionURLs: [URL] = fullURLToPackageFolderCurrentlyBeingProcessed.packageVersionURLs
                    else
                    {
                        if targetFolder.appendingPathComponent(item, conformingTo: .fileURL).isDirectory
                        {
                            AppConstants.shared.logger.error("Failed while getting package version for package \(fullURLToPackageFolderCurrentlyBeingProcessed.lastPathComponent). Package does not have any version installed.")
                            throw PackageLoadingError.packageDoesNotHaveAnyVersionsInstalled(item)
                        }
                        else
                        {
                            AppConstants.shared.logger.error("Failed while getting package version for package \(fullURLToPackageFolderCurrentlyBeingProcessed.lastPathComponent). Package is not a folder")
                            throw PackageLoadingError.packageIsNotAFolder(item, targetFolder.appendingPathComponent(item, conformingTo: .fileURL))
                        }
                    }

                    do
                    {
                        if versionURLs.isEmpty
                        {
                            throw PackageLoadingError.packageDoesNotHaveAnyVersionsInstalled(item)
                        }

                        let wasPackageInstalledIntentionally: Bool = try await targetFolder.checkIfPackageWasInstalledIntentionally(versionURLs)

                        let foundPackage: BrewPackage = .init(
                            name: item,
                            type: targetFolder.packageType,
                            installedOn: fullURLToPackageFolderCurrentlyBeingProcessed.creationDate,
                            versions: versionURLs.versions,
                            installedIntentionally: wasPackageInstalledIntentionally,
                            sizeInBytes: fullURLToPackageFolderCurrentlyBeingProcessed.directorySize
                        )

                        return foundPackage
                    }
                    catch
                    {
                        throw error
                    }
                }
            }

            var loadedPackages: Set<BrewPackage> = .init()
            for try await package in taskGroup
            {
                loadedPackages.insert(package)
            }
            return loadedPackages
        }

        return loadedPackages
    }
    catch
    {
        AppConstants.shared.logger.error("Failed while accessing folder: \(error)")
        throw error
    }
}
*/
 
// MARK: - Sub-functions

private extension URL
{
    /// ``[URL]`` to packages without hidden files or symlinks.
    /// e.g. only actual package URLs
    var validPackageURLs: [String]?
    {
        let items: [String]? = try? FileManager.default.contentsOfDirectory(atPath: path).filter { !$0.hasPrefix(".") }.filter
        { item in
            /// Filter out all symlinks from the folder
            let completeURLtoItem: URL = self.appendingPathComponent(item, conformingTo: .folder)

            guard let isSymlink = completeURLtoItem.isSymlink()
            else
            {
                return false
            }

            return !isSymlink
        }

        return items
    }

    /// Get URLs to a package's versions
    var packageVersionURLs: [URL]?
    {
        AppConstants.shared.logger.debug("Will check URL \(self)")
        do
        {
            let versions: [URL] = try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: [.isHiddenKey], options: .skipsHiddenFiles)

            if versions.isEmpty
            {
                AppConstants.shared.logger.warning("Package URL \(self, privacy: .public) has no versions installed")

                return nil
            }

            AppConstants.shared.logger.debug("URL \(self) has these versions: \(versions))")

            return versions
        }
        catch
        {
            AppConstants.shared.logger.error("Failed while loading version for package \(lastPathComponent, privacy: .public) at URL \(self, privacy: .public)")

            return nil
        }
    }
}

extension [URL]
{
    /// Returns an array of versions from an array of URLs to available versions
    var versions: [String]
    {
        return map
        { versionURL in
            versionURL.lastPathComponent
        }
    }
}

// MARK: - Getting list of URLs in folder

func getContentsOfFolder(targetFolder: URL, options: FileManager.DirectoryEnumerationOptions? = nil) throws -> [URL]
{
    do
    {
        if let options
        {
            return try FileManager.default.contentsOfDirectory(at: targetFolder, includingPropertiesForKeys: nil, options: options)
        }
        else
        {
            return try FileManager.default.contentsOfDirectory(at: targetFolder, includingPropertiesForKeys: nil)
        }
    }
    catch let folderReadingError
    {
        AppConstants.shared.logger.error("\(folderReadingError.localizedDescription)")
        
        throw folderReadingError
    }
}
