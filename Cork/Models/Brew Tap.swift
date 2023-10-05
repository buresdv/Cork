//
//  Brew Tap.swift
//  Cork
//
//  Created by David Bureš on 10.02.2023.
//

import Foundation

struct BrewTap: Identifiable, Hashable
{
    let id = UUID()
    let name: String
    
    var isBeingModified: Bool = false
    
    mutating func changeBeingModifiedStatus() -> Void
    {
        self.isBeingModified.toggle()
    }
}
