//
//  Brew Data Storage.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation

class BrewDataStorage: ObservableObject
{
    @Published var installedFormulae = [BrewPackage]()
    @Published var installedCasks = [BrewPackage]()
}

class AvailableTaps: ObservableObject
{
    @Published var tappedTaps = [BrewTap]()
}
