//
//  Get Contents of Folder.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation

func getContentsOfFolder(targetFolder: URL) async -> [BrewPackage] {
    var contentsOfFolder = [BrewPackage]()

    var temporaryVersionStorage = [String]()

    do {
        let items = try FileManager.default.contentsOfDirectory(atPath: targetFolder.path)

        for item in items {
            do {
                let versions = try FileManager.default.contentsOfDirectory(
                    atPath: targetFolder.appendingPathComponent(
                        item, conformingTo: .folder).path
                )
                // Check if what we're about to add are actual versions or just some supporting folders
                for version in versions {
                    print("Scanned version: \(version)")

                    if version != ".metadata" {
                        print("Found desirable version: \(version). Appending to temporary package list")

                        temporaryVersionStorage.append(version)
                    } else {
                        print("Found non-desirable version: \(version). Ignoring")
                    }
                }

                print("URL of this package: \(targetFolder.appendingPathComponent(item, conformingTo: .folder))")

                /// What the fuck?
                let installedOn: Date? = (try? FileManager.default.attributesOfItem(
                    atPath: targetFolder.appendingPathComponent(item, conformingTo: .folder).path)
                )?[.creationDate] as? Date

                let folderSizeRaw: Int64? = directorySize(
                    url: targetFolder.appendingPathComponent(item, conformingTo: .directory)
                )

                print("\n Installation date for package \(item) at path \(targetFolder.appendingPathComponent(item, conformingTo: .directory)) is \(installedOn) \n")

                contentsOfFolder.append(
                    BrewPackage(
                        name: item,
                        installedOn: installedOn,
                        versions: temporaryVersionStorage,
                        sizeInBytes: folderSizeRaw
                    )
                )

                temporaryVersionStorage = [String]()
            } catch let error as NSError {
                print("Failed while getting package version: \(error)")
            }
        }
    } catch let error as NSError {
        print("Failed while accessing foldeR: \(error)")
    }

    return contentsOfFolder
}
