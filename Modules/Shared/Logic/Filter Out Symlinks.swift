//
//  Filter Out Symlinks.swift
//  Cork
//
//  Created by David Bureš - P on 28.10.2025.
//

import Foundation

public extension [URL]
{
    /// Filter out all symlinks from an array of URLs
    var withoutSymlinks: [URL]
    {
        return self.filter
        { url in
            /// If the existence of a symlink cannot be verified, be safe and return `false`
            guard let isSymlink = url.isSymlink()
            else
            {
                return false
            }

            /// `isSymlink` is `true` for a symlink. Therefore, if we want to filter out symlinks, we have to return the opposite of `true`, which is `false`
            return !isSymlink
        }
    }
}
