//
//  Defaults.swift
//  CorkShared
//
//  Created by David Bureš - P on 10.03.2025.
//

import Foundation
import Defaults

public extension Defaults.Keys
{
    /// The last version of Cork the user submitted
    static let lastSubmittedCorkVersion: Key<String> = .init("lastSubmittedCorkVersion", default: "")
}
