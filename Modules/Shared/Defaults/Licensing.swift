//
//  Licensing.swift
//  CorkShared
//
//  Created by David Bureš - P on 15.05.2025.
//

import Foundation
import Defaults

public extension Defaults.Keys
{
    // MARK: - Demo
    /// When the demo was activated. If it's `nil`, it hasn't been activated
    static let demoActivatedAt: Key<Date?> = .init("demoActivatedAt", default: nil)
    
    // MARK: - Licensing
    /// Whether the licensing workflow was completed by either putting in a license, or activating the demo
    static let hasFinishedLicensingWorkflow: Key<Bool> = .init("hasFinishedLicensingWorkflow", default: false)
    
    /// Whether the user has put in a valid license email
    static let hasValidatedEmail: Key<Bool> = .init("hasValidatedEmail", default: false)
}
