//
//  Demo.swift
//  CorkShared
//
//  Created by David Bureš - P on 15.05.2025.
//

import Foundation
import Defaults

public extension Defaults.Keys
{
    /// When the demo was activated. If it's `nil`, it hasn't been activated
    static let demoActivatedAt: Key<Date?> = .init("demoActivatedAt", default: nil)
}
