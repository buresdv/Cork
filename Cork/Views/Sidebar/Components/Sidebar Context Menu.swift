//
//  Sidebar Context Menu.swift
//  Cork
//
//  Created by David Bureš - P on 22.04.2025.
//

import SwiftUI
import CorkShared
import Defaults
import CorkModels

struct SidebarContextMenu: View
{
    @Environment(AppState.self) var appState: AppState
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker
    @Environment(OutdatedPackagesTracker.self) var outdatedPackagesTracker: OutdatedPackagesTracker
    
    let package: BrewPackage
    
    var isPackageOutdated: Bool
    {
        if outdatedPackagesTracker.allDisplayableOutdatedPackages.contains(where: { $0.package.name == package.name })
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    var body: some View
    {
        TagUntagButton(package: package)
        
        PinUnpinButton(package: package)
        
        Divider()
    
        if isPackageOutdated
        {
            UpdatePackageButton(packageToUpdate: package)
        }

        Divider()

        UninstallPackageButton(package: package)

        PurgePackageButton(package: package)

        Divider()
        
        RevealPackageInFinderButton(package: package)
    }
}
