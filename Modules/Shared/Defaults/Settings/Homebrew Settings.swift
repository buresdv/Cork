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
    // MARK: - Error checking
    static let strictlyCheckForHomebrewErrors: Key<Bool> = .init("strictlyCheckForHomebrewErrors", default: false)
    
    // MARK: - Analytics
    /// Whether to allow anonymous Homebrew analytics
    static let allowBrewAnalytics: Key<Bool> = .init("allowBrewAnalytics", default: true)
    
    // MARK: - Developer settings
    static let allowAdvancedHomebrewSettings: Key<Bool> = .init("allowAdvancedHomebrewSettings", default: false)
    
    static let customHomebrewPath: Key<URL?> = .init("customHomebrewPath", default: nil)
}
