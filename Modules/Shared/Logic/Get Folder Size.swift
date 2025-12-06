//
//  Get Folder Size.swift
//  Cork
//
//  Created by David Bureš on 09.02.2023.
//

import Foundation

public extension URL
{
    var directorySize: Int64
    {
        let contents: [URL]
        do
        {
            contents = try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey])
        }
        catch
        {
            return 0
        }

        var size: Int64 = 0

        for url in contents
        {
            let isDirectoryResourceValue: URLResourceValues
            do
            {
                isDirectoryResourceValue = try url.resourceValues(forKeys: [.isDirectoryKey])
            }
            catch
            {
                continue
            }

            if isDirectoryResourceValue.isDirectory == true
            {
                size += url.directorySize
            }
            else
            {
                let fileSizeResourceValue: URLResourceValues
                do
                {
                    fileSizeResourceValue = try url.resourceValues(forKeys: [.fileSizeKey])
                }
                catch
                {
                    continue
                }

                size += Int64(fileSizeResourceValue.fileSize ?? 0)
            }
        }

        return size
    }
}
