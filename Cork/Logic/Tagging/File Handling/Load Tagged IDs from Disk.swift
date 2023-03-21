//
//  Load Tagged IDs from Disk.swift
//  Cork
//
//  Created by David Bureš on 21.03.2023.
//

import Foundation

func loadTaggedIDsFromDisk() throws -> Set<UUID>
{
    var uuidSet: Set<UUID> = .init()
    
    do
    {
        let rawuuidStringFromFile: String = try String(contentsOf: AppConstants.metadataFilePath, encoding: .utf8)
        let uuidsAsStringsArray: [String] = rawuuidStringFromFile.components(separatedBy: ":")
        
        for uuidAsString in uuidsAsStringsArray
        {
            uuidSet.insert(UUID(uuidString: uuidAsString)!)
        }
        
    }
    catch let dataReadingError as NSError
    {
        print("Failed while reading data from disk: \(dataReadingError)")
    }
    
    print("Loaded UUID set: \(uuidSet)")
    
    return uuidSet
}
