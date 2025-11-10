//
//  Modifiable.swift
//  CorkModels
//
//  Created by David Bureš - P on 10.11.2025.
//

import Foundation

/// Defines a model that can be modified, and reflect the status of the modification in the UI
public protocol Modifiable: Sendable
{
    var isBeingModified: Bool { get set }
}
