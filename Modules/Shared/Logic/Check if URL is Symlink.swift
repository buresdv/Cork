//
//  Check if URL is Symlink.swift
//  Cork
//
//  Created by David Bureš - P on 28.10.2025.
//

import Foundation

public extension URL
{
    func isSymlink() -> Bool?
    {
        do
        {
            let fileAttributes: URLResourceValues = try resourceValues(forKeys: [.isSymbolicLinkKey])

            return fileAttributes.isSymbolicLink
        }
        catch let symlinkCheckingError
        {
            AppConstants.shared.logger.error("Error checking if \(self) is symlink: \(symlinkCheckingError)")

            return nil
        }
    }
}
