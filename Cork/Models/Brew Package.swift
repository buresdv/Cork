//
//  Brew Package.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation

struct BrewPackage: Identifiable
{
    let id = UUID()
    let name: String
    let versions: [String]
}
