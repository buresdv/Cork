//
//  Get Contents of Folder.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation
import SwiftyJSON


func getContentsOfFolder(targetFolder: URL, appState: AppState) async -> Set<BrewPackage>
{
    var contentsOfFolder: Set<BrewPackage> = .init()

    var temporaryVersionStorage: [String] = .init()
    var temporaryURLStorage: [URL] = .init()

    do
    {
        let items = try FileManager.default.contentsOfDirectory(atPath: targetFolder.path)

        for item in items
        {
            do
            {
                let versions = try FileManager.default.contentsOfDirectory(at: targetFolder.appendingPathComponent(item, conformingTo: .folder), includingPropertiesForKeys: [.isHiddenKey], options: .skipsHiddenFiles)

                for version in versions
                { // Check if what we're about to add are actual versions or just some supporting folders
                    AppConstants.logger.debug("Scanned version: \(version)")

                    AppConstants.logger.debug("Found desirable version: \(version). Appending to temporary package list")
                    
                    temporaryURLStorage.append(targetFolder.appendingPathComponent(item, conformingTo: .folder).appendingPathComponent(version.lastPathComponent, conformingTo: .folder))
                    
                    AppConstants.logger.debug("URL to package \(item) is \(temporaryURLStorage)")

                    temporaryVersionStorage.append(version.lastPathComponent)
                }

                AppConstants.logger.debug("URL of this package: \(targetFolder.appendingPathComponent(item, conformingTo: .folder))")

                /// What the fuck?
                let installedOn: Date? = (try? FileManager.default.attributesOfItem(atPath: targetFolder.appendingPathComponent(item, conformingTo: .folder).path))?[.creationDate] as? Date

                let folderSizeRaw: Int64? = directorySize(url: targetFolder.appendingPathComponent(item, conformingTo: .directory))

                AppConstants.logger.debug("\n Installation date for package \(item) at path \(targetFolder.appendingPathComponent(item, conformingTo: .directory)) is \(installedOn ?? Date()) \n")

                // let installedOn: Date? = try? URL(string: item)!.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate

                if targetFolder.path.contains("Cellar")
                {
                    /// Check if the package has any versions installed
                    if let localPackagePath: URL = temporaryURLStorage.first
                    {
                        /// Find out whether the packages have been installed intentionally
                        let localPackageInfoJSONPath: URL = localPackagePath.appendingPathComponent("INSTALL_RECEIPT.json", conformingTo: .json)
                        async let localPackageInfoJSON: JSON = parseJSON(from: String(contentsOfFile: localPackageInfoJSONPath.path, encoding: .utf8))
                        
                        var wasPackageInstalledIntentionally: Bool = false
                        if FileManager.default.fileExists(atPath: localPackageInfoJSONPath.path)
                        {
                            wasPackageInstalledIntentionally = try! await localPackageInfoJSON["installed_on_request"].boolValue
                        }

                        AppConstants.logger.info("Package \(item) \(wasPackageInstalledIntentionally ? "was installed intentionally" : "was not installed intentionally")")
                        
                        contentsOfFolder.insert(BrewPackage(name: item, isCask: false, installedOn: installedOn, versions: temporaryVersionStorage, installedIntentionally: wasPackageInstalledIntentionally, sizeInBytes: folderSizeRaw))
                    }
                    else
                    {
                        AppConstants.logger.error("\(item, privacy: .public) does not have any versions installed")
                        await appState.showAlert(errorToShow: .installedPackageHasNoVersions(corruptedPackageName: item))
                    }
                }
                else
                {
                    contentsOfFolder.insert(BrewPackage(name: item, isCask: true, installedOn: installedOn, versions: temporaryVersionStorage, sizeInBytes: folderSizeRaw))
                }

                temporaryVersionStorage = [String]()
                temporaryURLStorage = [URL]()
            }
            catch let error as NSError
            {
                AppConstants.logger.error("Failed while getting package version: \(error)")
            }
        }
    }
    catch let error as NSError
    {
        AppConstants.logger.error("Failed while accessing folder: \(error)")
    }

    return contentsOfFolder
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
