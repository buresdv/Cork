//
//  Delete Cached Downloads.swift
//  Cork
//
//  Created by David Bureš on 25.02.2023.
//

import Foundation
import CorkShared
import CorkModels

func deleteCachedDownloads() throws(CachedDownloadDeletionError)
{
    let shouldStrictlyCheckForHomebrewErrors: Bool = UserDefaults.standard.bool(forKey: "strictlyCheckForHomebrewErrors")
    
    /// This folder has the symlinks, so we have do **delete ONLY THE SYMLINKS**
    do
    {
        for url in try AppConstants.shared.brewCachedFormulaeDownloadsPath.getContents()
        {
            if let isSymlink = url.isSymlink()
            {
                if isSymlink
                {
                    try? FileManager.default.removeItem(at: url)
                }
                else
                {
                    AppConstants.shared.logger.info("Ignoring cached download at location \(url, privacy: .auto)")
                }
            }
            else
            {
                AppConstants.shared.logger.warning("Could not check symlink status of \(url)")
            }
        }
    }
    catch let brewCachedFormulaeDownloadsFolderReadingError
    {
        AppConstants.shared.logger.error("Failed while deleting cached downloads (brewCachedFormulaeDownloadsPath): \(brewCachedFormulaeDownloadsFolderReadingError)")
        
        if shouldStrictlyCheckForHomebrewErrors
        {
            throw .couldNotReadContentsOfCachedFormulaeDownloadsFolder(associatedError: brewCachedFormulaeDownloadsFolderReadingError.localizedDescription)
        }
    }

    /// This folder has the symlinks, so we have to **delete ONLY THE SYMLINKS**
    do
    {
        for url in try AppConstants.shared.brewCachedCasksDownloadsPath.getContents()
        {
            if let isSymlink = url.isSymlink()
            {
                if isSymlink
                {
                    try? FileManager.default.removeItem(at: url)
                }
                else
                {
                    AppConstants.shared.logger.info("Ignoring cached download at location \(url, privacy: .auto)")
                }
            }
            else
            {
                AppConstants.shared.logger.warning("Could not check symlink status of \(url)")
            }
        }
    }
    catch let brewCachedCasksDownloadsFolderReadingError
    {
        AppConstants.shared.logger.error("Failed while deleting cached downloads (brewCachedCasksDownloadsPath): \(brewCachedCasksDownloadsFolderReadingError)")
        
        if shouldStrictlyCheckForHomebrewErrors
        {
            throw .couldNotReadContentsOfCachedDownloadsFolder(associatedError: brewCachedCasksDownloadsFolderReadingError.localizedDescription)
        }
    }

    /// This folder has the downloads themselves, so we have do **DELETE EVERYTHING THAT IS NOT A SYMLINK**
    do
    {
        for url in try AppConstants.shared.brewCachedDownloadsPath.getContents()
        {
            if let isSymlink = url.isSymlink()
            {
                if isSymlink
                {
                    AppConstants.shared.logger.info("Ignoring cached download at location \(url, privacy: .auto)")
                }
                else
                {
                    try? FileManager.default.removeItem(at: url)
                }
            }
            else
            {
                AppConstants.shared.logger.warning("Could not check symlink status of \(url)")
            }
        }
    }
    catch let brewCachedDownloadsFolderReadingError
    {
        AppConstants.shared.logger.error("Failed while deleting cached downloads (brewCachedDownloadsPath): \(brewCachedDownloadsFolderReadingError)")
        
        if shouldStrictlyCheckForHomebrewErrors
        {
            throw .couldNotReadContentsOfCachedDownloadsFolder(associatedError: brewCachedDownloadsFolderReadingError.localizedDescription)
        }
    }
}
