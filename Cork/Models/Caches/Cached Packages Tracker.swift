//
//  Cached Packages Tracker.swift
//  Cork
//
//  Created by David Bureš - P on 16.01.2025.
//

import Foundation
import SwiftUI
import CorkShared

class CachedPackagesTracker: ObservableObject
{
    @Published var cachedDownloadsFolderSize: Int64 = AppConstants.shared.brewCachedDownloadsPath.directorySize
    @Published var cachedDownloads: [CachedDownload] = .init()

    private var cachedDownloadsTemp: [CachedDownload] = .init()
}
