//
//  Cached Download.swift
//  Cork
//
//  Created by David Bureš on 04.11.2023.
//

import Charts
import Foundation
import SwiftUI

public struct CachedDownload: Identifiable, Hashable
{
    public var id: UUID = .init()

    public let packageName: String
    public let sizeInBytes: Int

    public var packageType: CachedDownload.CachedDownloadType?
    
    public enum CachedDownloadType: String, CustomStringConvertible, Plottable
    {
        case formula
        case cask
        case other
        case unknown

        public var description: String
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

        public var color: Color
        {
            switch self
            {
            case .formula:
                return BrewPackage.PackageType.formula.color
            case .cask:
                return BrewPackage.PackageType.cask.color
            case .other:
                return .mint
            default:
                return .gray
            }
        }
    }
}
