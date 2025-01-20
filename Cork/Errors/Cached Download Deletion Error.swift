//
//  Cached Download Deletion Error.swift
//  Cork
//
//  Created by David Bureš - P on 20.01.2025.
//

import Foundation

enum CachedDownloadDeletionError: LocalizedError
{
    case couldNotReadContentsOfCachedFormulaeDownloadsFolder(associatedError: String)

    case couldNotReadContentsOfCachedCasksDownloadsFolder(associatedError: String)

    case couldNotReadContentsOfCachedDownloadsFolder(associatedError: String)

    var errorDescription: String?
    {
        switch self
        {
        case .couldNotReadContentsOfCachedFormulaeDownloadsFolder(let associatedError):
            return String(localized: "error.cache-deletion.could-not-read-contents-of-cached-formulae-downloads-folder")
        case .couldNotReadContentsOfCachedCasksDownloadsFolder(let associatedError):
            return String(localized: "error.cache-deletion.could-not-read-contents-of-cached-casks-downloads-folder")
        case .couldNotReadContentsOfCachedDownloadsFolder(let associatedError):
            return String(localized: "error.cache-deletion.could-not-read-contents-of-cached-downloads-folder")
        }
    }
}
