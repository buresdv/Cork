//
//  Cached Downloads Tacker Dependency.swift
//  CorkShared
//
//  Created by David Bureš - P on 29.04.2026.
//

import Foundation
import FactoryKit

public extension Container
{
    @MainActor
    var cachedDownloadsTracker: Factory<CachedDownloadsTracker>
    {
        Factory(self)
        {
            CachedDownloadsTracker()
        }
        .singleton
    }
}
