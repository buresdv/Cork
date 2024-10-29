//
//  Load Tagged IDs from Disk.swift
//  Cork
//
//  Created by David Bureš on 21.03.2023.
//

import Foundation
import CorkShared

func loadTaggedIDsFromDisk() throws -> Set<String>
{
    var nameSet: Set<String> = .init()

    do
    {
        let rawPackageNamesFromFile: String = try String(contentsOf: AppConstants.shared.metadataFilePath, encoding: .utf8)
        let packageNamesAsArray: [String] = rawPackageNamesFromFile.components(separatedBy: ":")

        for packageNameAsString in packageNamesAsArray
        {
            nameSet.insert(packageNameAsString)
        }
    }
    catch let dataReadingError as NSError
    {
        AppConstants.shared.logger.error("Failed while reading data from disk: \(dataReadingError, privacy: .public)")
    }

    AppConstants.shared.logger.debug("Loaded name set: \(nameSet, privacy: .public)")

    return nameSet
}
