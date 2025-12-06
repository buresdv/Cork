//
//  Package Dependency.swift
//  Cork
//
//  Created by David Bureš on 27.02.2023.
//

import Foundation

public struct BrewPackageDependency: Identifiable, Hashable
{
    public init(
        name: String,
        version: String,
        directlyDeclared: Bool
    ) {
        self.id = .init()
        self.name = name
        self.version = version
        self.directlyDeclared = directlyDeclared
    }
    
    public let id: UUID
    public let name: String
    public let version: String
    public let directlyDeclared: Bool
}
