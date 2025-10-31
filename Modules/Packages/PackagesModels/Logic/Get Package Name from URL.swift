//
//  Get Package Name from URL.swift
//  Cork
//
//  Created by David Bureš - P on 28.10.2025.
//

import Foundation

public extension URL
{
    func packageNameFromURL() -> String
    {
        return self.lastPathComponent
    }
}
