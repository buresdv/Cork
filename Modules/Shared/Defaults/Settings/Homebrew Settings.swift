//
//  Homebrew Settings.swift
//  Cork
//
//  Created by David Bureš - P on 14.05.2025.
//

import Foundation
import Defaults

public extension Defaults.Keys
{
    // MARK: - Analytics
    /// Whether to allow anonymous Homebrew analytics
    static let allowBrewAnalytics: Key<Bool> = .init("allowBrewAnalytics", default: true)
    
    // MARK: - Developer settings
    static let customHomebrewPath: Key<URL?> = .init("customHomebrewPath", default: nil)
}
