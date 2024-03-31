//
//  Check if URL is Symlink.swift
//  Cork
//
//  Created by David Bureš on 25.02.2023.
//

import Foundation

func isSymlink(at url: URL) -> Bool
{
    
    var isSymlink: Bool?
    
    do
    {
        let fileAttributes = try url.resourceValues(forKeys: [.isSymbolicLinkKey])
        
        isSymlink = fileAttributes.isSymbolicLink
    }
    catch let symlinkCheckingError as NSError
    {
        AppConstants.logger.error("\(symlinkCheckingError.localizedDescription, privacy: .public)")
    }
    
    return isSymlink!
}
