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
    
    /// The time frame used for getting top packages
    static let discoverabilityDaySpan: Key<DiscoverabilityDaySpans> = .init("discoverabilityDaySpan", default: .month)
    
    /// The time span the top packages should be sorted by
    static let sortTopPackagesBy: Key<TopPackageSorting> = .init("sortTopPackagesBy", default: .mostDownloads)
}
