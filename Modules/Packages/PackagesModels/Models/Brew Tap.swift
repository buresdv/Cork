//
//  Brew Tap.swift
//  Cork
//
//  Created by David Bureš - P on 28.10.2025.
//

import Foundation

public struct BrewTap: Identifiable, Hashable, Sendable
{
    public let id: UUID = .init()
    let name: String

    var isBeingModified: Bool = false

    mutating func changeBeingModifiedStatus()
    {
        isBeingModified.toggle()
    }
}
