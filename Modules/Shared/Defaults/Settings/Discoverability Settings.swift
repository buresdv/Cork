//
//  Discoverability Settings.swift
//  Cork
//
//  Created by David Bureš - P on 14.05.2025.
//

import Foundation
import Defaults

public extension Defaults.Keys
{
    /// Whether to enable top packages
    static let enableDiscoverability: Key<Bool> = .init("enableDiscoverability", default: false)
    
    /// Sorting type of top packages in the package installed
    static let sortTopPackagesBy: Key<TopPackageSorting> = .init("sortTopPackagesBy", default: .mostDownloads)
}
