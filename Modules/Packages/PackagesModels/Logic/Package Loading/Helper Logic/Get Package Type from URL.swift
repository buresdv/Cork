//
//  Get Package Type from URL.swift
//  Cork
//
//  Created by David Bureš on 13.11.2024.
//

import Foundation
import CorkModels

public extension URL
{
    /// Determine a package's type type from its URL
    var packageType: BrewPackage.PackageType
    {
        if self.pathComponents.contains("Cellar")
        {
            return .formula
        }
        else
        {
            return .cask
        }
    }
}
