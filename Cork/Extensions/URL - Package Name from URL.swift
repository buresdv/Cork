//
//  URL - Package Name from URL.swift
//  Cork
//
//  Created by David Bureš - P on 18.01.2025.
//

import Foundation

extension URL
{
    func packageNameFromURL() -> String
    {
        return self.lastPathComponent
    }
}
