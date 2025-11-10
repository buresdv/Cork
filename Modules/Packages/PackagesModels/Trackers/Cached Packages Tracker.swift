//
//  Cached Packages Tracker.swift
//  Cork
//
//  Created by David Bureš - P on 16.01.2025.
//

import Foundation
import SwiftUI
import CorkShared

@Observable @MainActor
public class CachedDownloadsTracker
{
    public init()
    {
        self.cachedDownloads = .init()
        self.cachedDownloadsTemp = .init()
    }
    
    public var cachedDownloads: [CachedDownload] = .init()

    private var cachedDownloadsTemp: [CachedDownload] = .init()
    
    /// Calculate the size of the cached downloads dynamically without accessing the file system for the operation
    public var cachedDownloadsSize: Int
    {
        return cachedDownloads.reduce(0) { $0 + $1.sizeInBytes }
    }
}
