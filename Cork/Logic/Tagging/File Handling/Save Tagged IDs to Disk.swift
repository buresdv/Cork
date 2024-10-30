//
//  Save Tagged IDs to Disk.swift
//  Cork
//
//  Created by David Bureš on 21.03.2023.
//

import Foundation
import CorkShared

@MainActor
func saveTaggedIDsToDisk(appState: AppState) throws
{
    let namesAsString: String = appState.taggedPackageNames.compactMap { $0 }.joined(separator: ":")
    AppConstants.shared.logger.debug("Names as string: \(namesAsString, privacy: .public)")

    do
    {
        try namesAsString.write(to: AppConstants.shared.metadataFilePath, atomically: true, encoding: .utf8)
    }
    catch let writingError as NSError
    {
        AppConstants.shared.logger.error("Error while writing to file: \(writingError, privacy: .public)")
    }
}
