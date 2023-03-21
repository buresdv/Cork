//
//  Save Tagged IDs to Disk.swift
//  Cork
//
//  Created by David Bureš on 21.03.2023.
//

import Foundation

func saveTaggedIDsToDisk(appState: AppState) throws
{
    let uuidsAsString: String = appState.taggedPackageIDs.compactMap { $0.uuidString }.joined(separator: ":")
    print("UUIDS as string: \(uuidsAsString)")

    do
    {
        try uuidsAsString.write(to: AppConstants.metadataFilePath, atomically: true, encoding: .utf8)
    }
    catch let writingError as NSError
    {
        print("Error while writing to file: \(writingError)")
    }
}
