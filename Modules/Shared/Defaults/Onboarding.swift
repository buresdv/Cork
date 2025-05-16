//
//  Onboarding.swift
//  CorkShared
//
//  Created by David Bureš - P on 10.03.2025.
//

import Foundation
import Defaults

public extension Defaults.Keys
{
    /// Whether the user finished the onboarding process
    static let hasFinishedOnboarding: Key<Bool> = .init("hasFinishedOnboarding", default: false)
}
