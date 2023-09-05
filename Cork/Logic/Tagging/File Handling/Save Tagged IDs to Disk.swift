//
//  Save Tagged IDs to Disk.swift
//  Cork
//
//  Created by David Bureš on 21.03.2023.
//

import Foundation

@MainActor
func saveTaggedIDsToDisk(appState: AppState) throws
{
    let namesAsString: String = appState.taggedPackageNames.compactMap { $0 }.joined(separator: ":")
    print("Names as string: \(namesAsString)")

    do
    {
        try namesAsString.write(to: AppConstants.metadataFilePath, atomically: true, encoding: .utf8)
    }
    catch let writingError as NSError
    {
        print("Error while writing to file: \(writingError)")
    }
}
