//
//  Sidebar Context Menu.swift
//  Cork
//
//  Created by David Bureš - P on 22.04.2025.
//

import SwiftUI
import CorkShared

struct SidebarContextMenu: View
{
    @Environment(AppState.self) var appState: AppState
    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker
    
    @AppStorage("enableRevealInFinder") var enableRevealInFinder: Bool = false
    
    let package: BrewPackage
    
    var isPackageOutdated: Bool
    {
        if outdatedPackageTracker.displayableOutdatedPackages.contains(where: { $0.package.name == package.name })
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

        if enableRevealInFinder
        {
            Divider()

            Button
            {
                do
                {
                    try package.revealInFinder()
                }
                catch
                {
                    appState.showAlert(errorToShow: .couldNotFindPackageInParentDirectory)
                }
            } label: {
                Text("action.reveal-in-finder")
            }
        }
    }
}
