//
//  Outdated Package.swift
//  Cork
//
//  Created by David Bureš on 15.03.2023.
//

import Foundation
import IdentifiedCollections

class OutdatedPackageTracker: ObservableObject
{
    @Published var outdatedPackages: IdentifiedArrayOf<OutdatedPackage> = .init()
}
