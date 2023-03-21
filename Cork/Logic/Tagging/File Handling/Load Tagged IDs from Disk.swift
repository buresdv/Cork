//
//  Load Tagged IDs from Disk.swift
//  Cork
//
//  Created by David Bureš on 21.03.2023.
//

import Foundation

func loadTaggedIDsFromDisk() throws -> Set<String>
{
    var nameSet: Set<String> = .init()
    
    do
    {
        let rawPackageNamesFromFile: String = try String(contentsOf: AppConstants.metadataFilePath, encoding: .utf8)
        let packageNamesAsArray: [String] = rawPackageNamesFromFile.components(separatedBy: ":")
        
        for packageNameAsString in packageNamesAsArray
        {
            nameSet.insert(packageNameAsString)
        }
        
    }
    catch let dataReadingError as NSError
    {
        print("Failed while reading data from disk: \(dataReadingError)")
    }
    
    print("Loaded name set: \(nameSet)")
    
    return nameSet
}
