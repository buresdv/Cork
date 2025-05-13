//
//  Update Package Button.swift
//  Cork
//
//  Created by David Bureš - P on 22.04.2025.
//

import SwiftUI
import CorkShared

struct UpdatePackageButton: View
{
    
    @Environment(AppState.self) var appState: AppState
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker
    
    let packageToUpdate: BrewPackage
    
    var outdatedPackageFromTracker: [OutdatedPackage]
    {
        return outdatedPackageTracker.outdatedPackages.filter({ $0.package.name == packageToUpdate.name })
    }
    
    var body: some View
    {
        Button
        {
            appState.showSheet(ofType: .partialUpdate(packagesToUpdate: outdatedPackageFromTracker))
        } label: {
            Text("action.update-\(packageToUpdate.name)")
        }

    }
}
