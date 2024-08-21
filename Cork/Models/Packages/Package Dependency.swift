//
//  Package Dependency.swift
//  Cork
//
//  Created by David Bureš on 27.02.2023.
//

import Foundation

struct BrewPackageDependency: Identifiable, Hashable
{
    let id: UUID = .init()
    let name: String
    let version: String
    let directlyDeclared: Bool
}
