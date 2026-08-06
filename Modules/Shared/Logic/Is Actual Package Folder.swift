//
//  Is Actual Package Folder.swift
//  CorkShared
//
//  Created by David Bureš - P on 05.08.2026.
//

import Foundation
import DavidFoundation

public extension URL
{
    var isActualPackageFolder: Bool {
        guard self.isSymlink() != true
        else
        {
            AppConstants.shared.logger.debug("Hit symlink: \(self)")
            return false
        }

        /// Check if the item is actually a directory
        guard self.isDirectory
        else
        {
            AppConstants.shared.logger.warning("Skipping non-directory item in package folder: \(self)")
            return false
        }

        return true
    }
}
