//
//  Sort Alphabetically.swift
//  Cork
//
//  Created by David Bureš on 15.02.2023.
//

import Foundation
import IdentifiedCollections

func sortPackagesAlphabetically(_ packageArray: IdentifiedArrayOf<BrewPackage>) -> [BrewPackage]
{
    return packageArray.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
}
