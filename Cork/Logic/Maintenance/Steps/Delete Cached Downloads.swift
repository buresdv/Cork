//
//  Delete Cached Downloads.swift
//  Cork
//
//  Created by David Bureš on 25.02.2023.
//

import Foundation
import CorkShared

func deleteCachedDownloads()
{
    /// This folder has the symlinks, so we have do **delete ONLY THE SYMLINKS**
    for url in try! getContentsOfFolder(targetFolder: AppConstants.shared.brewCachedFormulaeDownloadsPath)
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

    /// This folder has the symlinks, so we have to **delete ONLY THE SYMLINKS**
    for url in try! getContentsOfFolder(targetFolder: AppConstants.shared.brewCachedCasksDownloadsPath)
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

    /// This folder has the downloads themselves, so we have do **DELETE EVERYTHING THAT IS NOT A SYMLINK**
    for url in try! getContentsOfFolder(targetFolder: AppConstants.shared.brewCachedDownloadsPath)
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
