//
//  Brew Data Storage.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation
import IdentifiedCollections

@MainActor
class BrewDataStorage: ObservableObject
{
    @Published var installedFormulae: IdentifiedArrayOf<BrewPackage> = .init()
    @Published var installedCasks: IdentifiedArrayOf<BrewPackage> = .init()
}

class AvailableTaps: ObservableObject
{
    @Published var addedTaps = [BrewTap]()
}
