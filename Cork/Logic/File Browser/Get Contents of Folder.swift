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
                
                print("Installation date for package \(item) is \(installedOn)")
                
                //let installedOn: Date? = try? URL(string: item)!.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate
                
                contentsOfFolder.append(BrewPackage(name: item, installedOn: installedOn, versions: temporaryVersionStorage))

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
