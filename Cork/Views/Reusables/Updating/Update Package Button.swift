//
//  Update Package Button.swift
//  Cork
//
//  Created by David Bureš - P on 22.04.2025.
//

import SwiftUI
import CorkShared
import CorkModels
import FactoryKit

struct UpdatePackageButton: View
{
    
    @InjectedObservable(\.appState) var appState: AppState
    @InjectedObservable(\.outdatedPackagesTracker) var outdatedPackagesTracker: OutdatedPackagesTracker
    
    let packageToUpdate: BrewPackage
    
    var outdatedPackageFromTracker: OutdatedPackage?
    {
        return outdatedPackagesTracker.outdatedPackages.first(where: { $0.package.getCompletePackageName() == packageToUpdate.getCompletePackageName() })
    }
    
    var body: some View
    {
        Button
        {
            if let outdatedPackageFromTracker
            {
                outdatedPackagesTracker.setOnlyOnePackageToSelectedState(
                    packageToSingleOut: outdatedPackageFromTracker,
                    selectedStateToSetThatOnePackageTo: true
                )
                
                appState.showSheet(ofType: .update)
            }
            else
            {
                appState.showAlert(errorToShow: .couldNotFindPackageUUIDInList)
            }
            
        } label: {
            Text("action.update-\(packageToUpdate.name(withPrecision: .precise))")
        }

    }
}
