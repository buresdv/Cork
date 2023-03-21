//
//  Get Contents of Folder.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation

func getContentsOfFolder(targetFolder: URL) async -> [BrewPackage]
{
    var contentsOfFolder = [BrewPackage]()

    var temporaryVersionStorage = [String]()

    do
    {
        let items = try FileManager.default.contentsOfDirectory(atPath: targetFolder.path)

        for item in items
        {
            do
            {
                let versions = try FileManager.default.contentsOfDirectory(atPath: targetFolder.appendingPathComponent(item, conformingTo: .folder).path)

                for version in versions
                { // Check if what we're about to add are actual versions or just some supporting folders
                    print("Scanned version: \(version)")

                    if version != ".metadata"
                    {
                        print("Found desirable version: \(version). Appending to temporary package list")

                        temporaryVersionStorage.append(version)
                    }
                    else
                    {
                        print("Found non-desirable version: \(version). Ignoring")
                    }
                }

                print("URL of this package: \(targetFolder.appendingPathComponent(item, conformingTo: .folder))")

                /// What the fuck?
                let installedOn: Date? = (try? FileManager.default.attributesOfItem(atPath: targetFolder.appendingPathComponent(item, conformingTo: .folder).path))?[.creationDate] as? Date

                let folderSizeRaw: Int64? = directorySize(url: targetFolder.appendingPathComponent(item, conformingTo: .directory))

                print("\n Installation date for package \(item) at path \(targetFolder.appendingPathComponent(item, conformingTo: .directory)) is \(installedOn ?? Date()) \n")

                // let installedOn: Date? = try? URL(string: item)!.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate

                if targetFolder.path.contains("Cellar")
                {
                    contentsOfFolder.append(BrewPackage(name: item, isCask: false, installedOn: installedOn, versions: temporaryVersionStorage, sizeInBytes: folderSizeRaw))
                }
                else
                {
                    contentsOfFolder.append(BrewPackage(name: item, isCask: true, installedOn: installedOn, versions: temporaryVersionStorage, sizeInBytes: folderSizeRaw))
                }

                temporaryVersionStorage = [String]()
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
