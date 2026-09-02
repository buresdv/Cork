//
//  Cached Packages Tracker.swift
//  Cork
//
//  Created by David Bureš - P on 16.01.2025.
//

import CorkShared
import Foundation
import SwiftUI
import FactoryKit

@Observable @MainActor
public class CachedDownloadsTracker
{
    @LazyInjected(\.appConstants) @ObservationIgnored var appConstants: AppConstants
    
    public init()
    {
        self.cachedDownloads = .init()
        self.cachedDownloadsTemp = .init()
        self.lastSizeOfCachedPackageFolder = .init()
    }

    var lastSizeOfCachedPackageFolder: Int64 = 0

    public var cachedDownloads: [CachedDownload] = []

    private var cachedDownloadsTemp: [CachedDownload] = .init()

    /// Calculate the size of the cached downloads dynamically without accessing the file system for the operation
    public var cachedDownloadsSize: Int
    {
        return cachedDownloads.reduce(0) { $0 + $1.sizeInBytes }
    }
}
