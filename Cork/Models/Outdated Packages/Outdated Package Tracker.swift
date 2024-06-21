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
    
    var displayableOutdatedPackages: Set<OutdatedPackage>
    {
        if displayOnlyIntentionallyInstalledPackagesByDefault
        {
            return outdatedPackages.filter(\.package.installedIntentionally)
        }
        else
        {
            return outdatedPackages
        }
    }
}
