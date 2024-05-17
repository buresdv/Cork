//
//  Check if URL is Symlink.swift
//  Cork
//
//  Created by David Bureš on 25.02.2023.
//

import Foundation

extension URL
{
    func isSymlink() -> Bool
    {
        var isFileSymlink: Bool?
        
        do
        {
            let fileAttributes = try self.resourceValues(forKeys: [.isSymbolicLinkKey])
            
            isFileSymlink = fileAttributes.isSymbolicLink
        }
        catch let symlinkCheckingError as NSError
        {
            AppConstants.logger.error("Symlink checking error: \(symlinkCheckingError.localizedDescription, privacy: .public)")
        }
        
        return isFileSymlink!
    }
}
