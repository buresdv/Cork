//
//  Get Contents of Folder.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation
import SwiftyJSON

enum PackageLoadingError: Error
{
    case failedWhileLoadingPackages, failedWhileLoadingCertainPackage(String), packageDoesNotHaveAnyVersionsInstalled(String)
}

func getContentsOfFolder(targetFolder: URL) async throws -> Set<BrewPackage>
{
    do
    {
        let items = try FileManager.default.contentsOfDirectory(atPath: targetFolder.path).filter { !$0.hasPrefix(".") }.filter { item in
            /// Filter out all symlinks from the folder
            let completeURLtoItem: URL = targetFolder.appendingPathComponent(item, conformingTo: .folder)
            
            guard let isSymlink = completeURLtoItem.isSymlink() else
            {
                return false
            }
            
            return !isSymlink
        }

        let loadedPackages: Set<BrewPackage> = try await withThrowingTaskGroup(of: BrewPackage.self, returning: Set<BrewPackage>.self)
        { taskGroup in
            for item in items
            {
                taskGroup.addTask(priority: .high)
                {
                    do
                    {
                        var temporaryURLStorage: [URL] = .init()
                        var temporaryVersionStorage: [String] = .init()

                        let versions = try FileManager.default.contentsOfDirectory(at: targetFolder.appendingPathComponent(item, conformingTo: .folder), includingPropertiesForKeys: [.isHiddenKey], options: .skipsHiddenFiles)

                        for version in versions
                        {
                            AppConstants.logger.debug("Scanned version: \(version)")

                            AppConstants.logger.debug("Found desirable version: \(version). Appending to temporary package list")

                            temporaryURLStorage.append(targetFolder.appendingPathComponent(item, conformingTo: .folder).appendingPathComponent(version.lastPathComponent, conformingTo: .folder))

                            AppConstants.logger.debug("URL to package \(item) is \(temporaryURLStorage)")

                            temporaryVersionStorage.append(version.lastPathComponent)
                        }

                        AppConstants.logger.debug("URL of this package: \(targetFolder.appendingPathComponent(item, conformingTo: .folder))")

                        let installedOn: Date? = (try? FileManager.default.attributesOfItem(atPath: targetFolder.appendingPathComponent(item, conformingTo: .folder).path))?[.creationDate] as? Date

                        let folderSizeRaw: Int64? = directorySize(url: targetFolder.appendingPathComponent(item, conformingTo: .directory))

                        AppConstants.logger.debug("\n Installation date for package \(item) at path \(targetFolder.appendingPathComponent(item, conformingTo: .directory)) is \(installedOn ?? Date()) \n")

                        var wasPackageInstalledIntentionally = false
                        if targetFolder.path.contains("Cellar"),
                           let localPackagePath = temporaryURLStorage.first
                        {
                            let localPackageInfoJSONPath = localPackagePath.appendingPathComponent("INSTALL_RECEIPT.json", conformingTo: .json)
                            if FileManager.default.fileExists(atPath: localPackageInfoJSONPath.path)
                            {
                                async let localPackageInfoJSON: JSON = parseJSON(from: String(contentsOfFile: localPackageInfoJSONPath.path, encoding: .utf8))
                                wasPackageInstalledIntentionally = try! await localPackageInfoJSON["installed_on_request"].boolValue
                            }
                        }
                        AppConstants.logger.info("Package \(item) \(wasPackageInstalledIntentionally ? "was installed intentionally" : "was not installed intentionally")")

                        let foundPackage = BrewPackage(name: item, isCask: !targetFolder.path.contains("Cellar"), installedOn: installedOn, versions: temporaryVersionStorage, installedIntentionally: wasPackageInstalledIntentionally, sizeInBytes: folderSizeRaw)

                        print("Successfully found and loaded \(foundPackage.isCask ? "cask" : "formula"): \(foundPackage)")

                        return foundPackage
                    }
                    catch
                    {
                        AppConstants.logger.error("Failed while getting package version: \(error)")
                        throw PackageLoadingError.failedWhileLoadingCertainPackage(item)
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
