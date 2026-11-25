//
//  Package Dependency.swift
//  Cork
//
//  Created by David Bureš on 27.02.2023.
//

import Foundation

public class BrewPackageDependencyNoAssociatedPackage: Identifiable, Hashable
{
    public static func == (
        lhs: borrowing BrewPackageDependencyNoAssociatedPackage,
        rhs: borrowing BrewPackageDependencyNoAssociatedPackage
    ) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(self)
    }
    
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

public class BrewPackageDependency: BrewPackageDependencyNoAssociatedPackage
{
    public init(packageDependencyWithNoAssociatedPackage: BrewPackageDependencyNoAssociatedPackage, package: BrewPackage)
    {
        self.package = package
        
        super.init(
            name: packageDependencyWithNoAssociatedPackage.name,
            version: packageDependencyWithNoAssociatedPackage.version,
            directlyDeclared: packageDependencyWithNoAssociatedPackage.directlyDeclared
        )
        
    }
    
    public let package: BrewPackage
}
