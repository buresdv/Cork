//
//  Outdated Package.swift
//  Cork
//
//  Created by David Bureš on 15.03.2023.
//

import Foundation
import SwiftUI


class OutdatedPackageTracker: ObservableObject
{
    @AppStorage("displayOnlyIntentionallyInstalledPackagesByDefault") var displayOnlyIntentionallyInstalledPackagesByDefault: Bool = true
    
    @Published var outdatedPackages: Set<OutdatedPackage> = .init()
    
    @Published var allOutdatedPackages: Set<OutdatedPackage> = .init()
    {
        didSet
        {
            updateDisplayableOutdatedPackages()
        }
    }
    
    func updateDisplayableOutdatedPackages()
    {
        print("Updating outdated package list...")
        print("found these outdated packages: \(self.allOutdatedPackages)")
        
        if displayOnlyIntentionallyInstalledPackagesByDefault
        {
            outdatedPackages = allOutdatedPackages.filter(\.package.installedIntentionally)
        }
        else
        {
            outdatedPackages = allOutdatedPackages
        }
    }
}
