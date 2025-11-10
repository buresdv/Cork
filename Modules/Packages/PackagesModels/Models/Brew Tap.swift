//
//  Brew Tap.swift
//  Cork
//
//  Created by David Bureš - P on 28.10.2025.
//

import Foundation

public struct BrewTap: Identifiable, Hashable, Sendable
{
    public init(
        name: String,
        isBeingModified: Bool? = nil
    ) {
        self.id = .init()
        self.name = name
        self.isBeingModified = isBeingModified ?? false
    }
    
    public let id: UUID
    public let name: String

    public var isBeingModified: Bool

    public mutating func changeBeingModifiedStatus()
    {
        isBeingModified.toggle()
    }
}
