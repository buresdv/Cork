//
//  Corrupted Package.swift
//  Cork
//
//  Created by David Bureš - P on 28.10.2025.
//

import Foundation

public struct CorruptedPackage: Identifiable, Equatable
{
    public let id: UUID
    public let name: String
    
    public init(name: String)
    {
        self.id = .init()
        self.name = name
    }
}
