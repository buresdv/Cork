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
    
    // TODO: Merge this with the outdated package discovery logic in `Sidebar Context Menu`
    var isPackageOutdated: Bool
    {
        if outdatedPackagesTracker.allDisplayableOutdatedPackages.contains(where: { $0.package.name(withPrecision: .precise) == packageToUpdate.name(withPrecision: .precise) })
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    var outdatedPackageFromTracker: OutdatedPackage?
    {
        return outdatedPackagesTracker.outdatedPackages.first(where: { $0.package.getCompletePackageName() == packageToUpdate.getCompletePackageName() })
    }
    
    var isUpdatingDisabledForThisPackage: Bool
    {
        return packageToUpdate.isPinned || !isPackageOutdated
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
            Label("action.update-\(packageToUpdate.name(withPrecision: .inlineFormatted))", systemImage: "square.and.arrow.down")
        }
        .disabled(isUpdatingDisabledForThisPackage)
    }
}
