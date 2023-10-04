//
//  Outdated Package.swift
//  Cork
//
//  Created by David Bureš on 15.03.2023.
//

import Foundation


class OutdatedPackageTracker: ObservableObject
{
    @Published var outdatedPackages: Set<OutdatedPackage> = .init()
}
