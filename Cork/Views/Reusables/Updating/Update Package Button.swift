//
//  Update Package Button.swift
//  Cork
//
//  Created by David Bureš - P on 22.04.2025.
//

import SwiftUI
import CorkShared
import CorkModels

struct UpdatePackageButton: View
{
    
    @Environment(AppState.self) var appState: AppState
    @Environment(OutdatedPackagesTracker.self) var outdatedPackagesTracker: OutdatedPackagesTracker
    
    let packageToUpdate: BrewPackage
    
    var outdatedPackageFromTracker: [OutdatedPackage]
    {
        return outdatedPackagesTracker.outdatedPackages.filter({ $0.package.getCompletePackageName() == packageToUpdate.getCompletePackageName() })
    }
    
    var body: some View
    {
        Button
        {
            appState.showSheet(ofType: .partialUpdate(packagesToUpdate: outdatedPackageFromTracker))
        } label: {
            Text("action.update-\(packageToUpdate.getPackageName(withPrecision: .precise))")
        }

    }
}
