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
    /// Whether uninstallation and purges should have to be confirmed
    static let shouldRequestPackageRemovalConfirmation: Key<Bool> = .init("shouldRequestPackageRemovalConfirmation", default: false)
    
    // MARK: - Outdated packages
    /// Whether to show `--greedy` packages
    static let includeGreedyOutdatedPackages: Key<Bool> = .init("includeGreedyOutdatedPackages", default: false)
    
    // MARK: - Compatibility
    /// Whether to warn about packages incompatible with the user's system
    static let showCompatibilityWarning: Key<Bool> = .init("showCompatibilityWarning", default: true)
    
    // MARK: - Advanced
    /// Whether to show live Terminal outputs of varous operations
    static let showRealTimeTerminalOutputOfOperations: Key<Bool> = .init("showRealTimeTerminalOutputOfOperations", default: false)
    
    /// Whether to expand live Terminal outputs by default
    static let openRealTimeTerminalOutputByDefault: Key<Bool> = .init("openRealTimeTerminalOutputByDefault", default: false)
    
    /// Whether package EULAs should be accepted by default
    ///
    /// Fixes some hangup issues
    static let automaticallyAcceptEULA: Key<Bool> = .init("automaticallyAcceptEULA", default: false)
    
    // MARK: - Developer
    /// Whether to allow purging
    static let allowMoreCompleteUninstallations: Key<Bool> = .init("allowMoreCompleteUninstallations", default: false)
    
    /// Whether automatic cleanups after packages are enabled
    static let isAutomaticCleanupEnabled: Key<Bool> = .init("isAutomaticCleanupEnabled", default: true)
}
