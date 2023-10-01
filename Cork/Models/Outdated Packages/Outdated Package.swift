//
//  Outdated Package.swift
//  Cork
//
//  Created by David Bureš on 05.04.2023.
//

import Foundation

struct OutdatedPackage: Identifiable, Equatable
{
    let id: UUID = UUID()
    
    let package: BrewPackage
    
    var isMarkedForUpdating: Bool = true
}
