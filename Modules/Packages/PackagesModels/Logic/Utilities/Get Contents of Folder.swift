//
//  Get Contents of Folder.swift
//  Cork
//
//  Created by David Bureš - P on 09.11.2025.
//

import Foundation
import CorkShared

public extension URL
{
    /// Get the contents of a folder as a list of URLs to items in it
    func getContents(
        options: FileManager.DirectoryEnumerationOptions? = nil
    ) throws -> [URL]
    {
        do
        {
            if let options
            {
                return try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: options)
            }
            else
            {
                return try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil)
            }
        }
        catch let folderReadingError
        {
            AppConstants.shared.logger.error("\(folderReadingError.localizedDescription)")
            
            throw folderReadingError
        }
    }
}
