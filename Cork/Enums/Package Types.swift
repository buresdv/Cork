//
//  Package Types.swift
//  Cork
//
//  Created by David Bureš on 05.02.2023.
//

import Foundation
import Charts

enum PackageType: String, CustomStringConvertible, Plottable
{
    case formula
    case cask
    
    var description: String
    {
        switch self
        {
            case .formula:
                return String(localized: "package-details.type.formula")
            case .cask:
                return String(localized: "package-details.type.cask")
        }
    }
}
