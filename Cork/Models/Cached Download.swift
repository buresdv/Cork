//
//  Cached Download.swift
//  Cork
//
//  Created by David Bureš on 04.11.2023.
//

import Charts
import Foundation
import SwiftUI

struct CachedDownload: Identifiable, Hashable
{
    var id: UUID = .init()

    let packageName: String
    let sizeInBytes: Int

    var packageType: CachedDownload.CachedDownloadType?
    
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
            switch self
            {
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
}
