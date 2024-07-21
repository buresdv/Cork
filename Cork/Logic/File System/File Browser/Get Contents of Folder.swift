//
//  Get Contents of Folder.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation
import SwiftUI

enum PackageLoadingError: Error
{
    case failedWhileLoadingPackages(failureReason: LocalizedStringKey?), failedWhileLoadingCertainPackage(String, URL), packageDoesNotHaveAnyVersionsInstalled(String), packageIsNotAFolder(String, URL)
}

func getContentsOfFolder(targetFolder: URL) async throws -> Set<BrewPackage>
{
    do
    {
        guard let items = targetFolder.validPackageURLs
        else
        {
            throw PackageLoadingError.failedWhileLoadingPackages(failureReason: "alert.fatal.could-not-filter-invalid-packages")
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
                            AppConstants.logger.error("Failed while getting package version for package \(fullURLToPackageFolderCurrentlyBeingProcessed.lastPathComponent). Package does not have any version installed.")
                            throw PackageLoadingError.packageDoesNotHaveAnyVersionsInstalled(item)
                        }
                        else
                        {
                            AppConstants.logger.error("Failed while getting package version for package \(fullURLToPackageFolderCurrentlyBeingProcessed.lastPathComponent). Package is not a folder")
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

            var loadedPackages = Set<BrewPackage>()
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
        AppConstants.logger.error("Failed while accessing folder: \(error)")
        throw error
    }
}

// MARK: - Sub-functions
private extension URL
{
    /// ``[URL]`` to packages without hidden files or symlinks.
    /// e.g. only actual package URLs
    var validPackageURLs: [String]?
    {
        let items: [String]? = try? FileManager.default.contentsOfDirectory(atPath: self.path).filter { !$0.hasPrefix(".") }.filter
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

    /// This function checks whether the package was installed intentionally.
    /// - For Formulae, this info gets read from the install receipt
    /// - Casks are always instaled intentionally
    func checkIfPackageWasInstalledIntentionally(_ versionURLs: [URL]) async throws -> Bool
    {
        guard let localPackagePath = versionURLs.first
        else
        {
            throw PackageLoadingError.failedWhileLoadingCertainPackage(self.lastPathComponent, self)
        }

        if self.path.contains("Cellar")
        {
            let localPackageInfoJSONPath = localPackagePath.appendingPathComponent("INSTALL_RECEIPT.json", conformingTo: .json)
            if FileManager.default.fileExists(atPath: localPackageInfoJSONPath.path)
            {
                struct InstallRecepitParser: Codable
                {
                    let installedOnRequest: Bool
                }
                
                let decoder: JSONDecoder =
                {
                    let decoder: JSONDecoder = .init()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    return decoder
                }()
                
                do
                {
                    let installReceiptContents: Data = try .init(contentsOf: localPackageInfoJSONPath)
                    
                    do
                    {
                        return try decoder.decode(InstallRecepitParser.self, from: installReceiptContents).installedOnRequest
                    }
                    catch let installReceiptParsingError
                    {
                        AppConstants.logger.error("Failed to decode install receipt for package \(self.lastPathComponent) with error \(installReceiptParsingError.localizedDescription)")
                        
                        throw PackageLoadingError.failedWhileLoadingCertainPackage(self.lastPathComponent, self)
                    }
                }
                catch let installReceiptLoadingError
                {
                    AppConstants.logger.error("Failed to load contents of install receipt for package \(self.lastPathComponent) with error \(installReceiptLoadingError.localizedDescription)")
                    throw PackageLoadingError.failedWhileLoadingCertainPackage(self.lastPathComponent, self)
                }
            }
            else
            {
                throw PackageLoadingError.failedWhileLoadingCertainPackage(self.lastPathComponent, self)
            }
        }
        else if self.path.contains("Caskroom")
        {
            return true
        }
        else
        {
            throw PackageLoadingError.failedWhileLoadingCertainPackage(self.lastPathComponent, self)
        }
    }

    /// Determine a package's type type from its URL
    var packageType: PackageType
    {
        if self.path.contains("Cellar")
        {
            return .formula
        }
        else
        {
            return .cask
        }
    }

    /// Get URLs to a package's versions
    var packageVersionURLs: [URL]?
    {
        AppConstants.logger.debug("Will check URL \(self)")
        do
        {
            let versions: [URL] = try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: [.isHiddenKey], options: .skipsHiddenFiles)

            if versions.isEmpty
            {
                AppConstants.logger.warning("Package URL \(self, privacy: .public) has no versions installed")
                
                return nil
            }
            
            AppConstants.logger.debug("URL \(self) has these versions: \(versions))")
            
            return versions
        }
        catch
        {
            AppConstants.logger.error("Failed while loading version for package \(self.lastPathComponent, privacy: .public) at URL \(self, privacy: .public)")

            return nil
        }
    }
}

extension [URL]
{
    /// Returns an array of versions from an array of URLs to available versions
    var versions: [String]
    {
        return self.map
        { versionURL in
            versionURL.lastPathComponent
        }
    }
}

// MARK: - Getting list of URLs in folder
func getContentsOfFolder(targetFolder: URL, options: FileManager.DirectoryEnumerationOptions? = nil) -> [URL]
{
    var contentsOfFolder: [URL] = .init()

    do
    {
        if let options
        {
            contentsOfFolder = try FileManager.default.contentsOfDirectory(at: targetFolder, includingPropertiesForKeys: nil, options: options)
        }
        else
        {
            contentsOfFolder = try FileManager.default.contentsOfDirectory(at: targetFolder, includingPropertiesForKeys: nil)
        }
    }
    catch let folderReadingError as NSError
    {
        AppConstants.logger.error("\(folderReadingError.localizedDescription)")
    }

    return contentsOfFolder
}
