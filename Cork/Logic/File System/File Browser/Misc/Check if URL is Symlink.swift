//
//  Check if URL is Symlink.swift
//  Cork
//
//  Created by David Bureš on 25.02.2023.
//

import Foundation

extension URL
{
    func isSymlink() -> Bool?
    {
        do
        {
            let fileAttributes = try self.resourceValues(forKeys: [.isSymbolicLinkKey])
            
            return fileAttributes.isSymbolicLink
        }
        catch let symlinkCheckingError
        {
            AppConstants.logger.error("Error checking if \(self) is symlink: \(symlinkCheckingError)")
            
            return nil
        }
    }
}
