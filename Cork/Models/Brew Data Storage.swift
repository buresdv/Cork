//
//  Brew Data Storage.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation
import IdentifiedCollections
import SwiftUI

@MainActor
class BrewDataStorage: ObservableObject
{
    @Published var installedFormulae: Set<BrewPackage> = .init()
    @Published var installedCasks: Set<BrewPackage> = .init()
}

@MainActor
class AvailableTaps: ObservableObject
{
    @Published var addedTaps: Set<BrewTap> = .init()

    func insertTapIntoTracker(_ tap: BrewTap)
    {
        addedTaps.insert(tap)
    }
}
