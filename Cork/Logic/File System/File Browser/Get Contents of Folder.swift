//
//  Get Contents of Folder.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation
import SwiftyJSON
import IdentifiedCollections

func getContentsOfFolder(targetFolder: URL, appState: AppState) async -> IdentifiedArrayOf<BrewPackage>
{
    var contentsOfFolder: IdentifiedArrayOf<BrewPackage> = .init()

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
                    print("Scanned version: \(version)")

                    print("Found desirable version: \(version). Appending to temporary package list")
                    
                    temporaryURLStorage.append(targetFolder.appendingPathComponent(item, conformingTo: .folder).appendingPathComponent(version.lastPathComponent, conformingTo: .folder))
                    
                    print("URL to package \(item) is \(temporaryURLStorage)")

                    temporaryVersionStorage.append(version.lastPathComponent)
                }

                print("URL of this package: \(targetFolder.appendingPathComponent(item, conformingTo: .folder))")

                /// What the fuck?
                let installedOn: Date? = (try? FileManager.default.attributesOfItem(atPath: targetFolder.appendingPathComponent(item, conformingTo: .folder).path))?[.creationDate] as? Date

                let folderSizeRaw: Int64? = directorySize(url: targetFolder.appendingPathComponent(item, conformingTo: .directory))

                print("\n Installation date for package \(item) at path \(targetFolder.appendingPathComponent(item, conformingTo: .directory)) is \(installedOn ?? Date()) \n")

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

                        print("Package \(item) \(wasPackageInstalledIntentionally ? "was installed intentionally" : "was not installed intentionally")")
                        
                        contentsOfFolder.append(BrewPackage(name: item, isCask: false, installedOn: installedOn, versions: temporaryVersionStorage, installedIntentionally: wasPackageInstalledIntentionally, sizeInBytes: folderSizeRaw))
                    }
                    else
                    {
                        print("\(item) does not have any versions installed")
                        appState.corruptedPackage = item
                        appState.fatalAlertType = .installedPackageHasNoVersions
                        appState.isShowingFatalError = true
                    }
                }
                else
                {
                    contentsOfFolder.append(BrewPackage(name: item, isCask: true, installedOn: installedOn, versions: temporaryVersionStorage, sizeInBytes: folderSizeRaw))
                }

                temporaryVersionStorage = [String]()
                temporaryURLStorage = [URL]()
            }
            catch let error as NSError
            {
                print("Failed while getting package version: \(error)")
            }
        }
    }
    catch let error as NSError
    {
        print("Failed while accessing foldeR: \(error)")
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
        print(folderReadingError.localizedDescription)
    }

    return contentsOfFolder
}
