//
//  Outdated Package Type.swift
//  Cork
//
//  Created by David Bureš on 17.05.2024.
//

import Foundation
import Charts
import SwiftUI

enum CachedDownloadType: String, CustomStringConvertible, Plottable
{
    case formula
    case cask
    case other
    case unknown
    
    var description: String
    {
        switch self
        {
            case .formula:
                return String(localized: "package-details.type.formula")
            case .cask:
                return String(localized: "package-details.type.cask")
            case .other:
                return String(localized: "start-page.cached-downloads.graph.other-smaller-packages")
            default:
                return String(localized: "cached-downloads.type.unknown")
        }
    }
    
    var color: Color
    {
        switch self {
            case .formula:
                return .purple
            case .cask:
                return .orange
            case .other:
                return .mint
            default:
                return .gray
        }
    }
}
