//
//  Maintenance Settings.swift
//  Cork
//
//  Created by David Bureš - P on 14.05.2025.
//

import Foundation
import Defaults

public extension Defaults.Keys
{
    static let default_shouldUninstallOrphans: Key<Bool> = .init("default_shouldUninstallOrphans", default: true)
    static let default_shouldPurgeCache: Key<Bool> = .init("default_shouldPurgeCache", default: true)
    static let default_shouldDeleteDownloads: Key<Bool> = .init("default_shouldDeleteDownloads", default: true)
    static let default_shouldPerformHealthCheck: Key<Bool> = .init("default_shouldPerformHealthCheck", default: false)
}
