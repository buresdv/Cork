//
//  Packages Settings.swift
//  Cork
//
//  Created by David Bureš - P on 14.05.2025.
//

import Foundation
import Defaults

public extension Defaults.Keys
{
    // MARK: - Package removal
    
    // MARK: - Outdated packages
    /// Whether to show `--greedy` packages
    static let includeGreedyOutdatedPackages: Key<Bool> = .init("includeGreedyOutdatedPackages", default: false)
    
    // MARK: - Compatibility
    /// Whether to warn about packages incompatible with the user's system
    static let showCompatibilityWarning: Key<Bool> = .init("showCompatibilityWarning", default: true)
    
    // MARK: - Advanced
    /// Whether to show live Terminal outputs of varous operations
    static let showRealTimeTerminalOutputOfOperations: Key<Bool> = .init("showRealTimeTerminalOutputOfOperations", default: false)
    
    // MARK: - Developer
    /// Whether to allow purging
    static let allowMoreCompleteUninstallations: Key<Bool> = .init("allowMoreCompleteUninstallations", default: false)
}
