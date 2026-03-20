//
//  Sidebar Package Row.swift
//  Cork
//
//  Created by Seb Jachec on 08/09/2023.
//

import CorkShared
import SwiftUI
import Defaults
import CorkModels
import FactoryKit

struct SidebarPackageRow: View
{
    let package: BrewPackage

    @Default(.enableSwipeActions) var enableSwipeActions: Bool

    @InjectedObservable(\.appState) var appState: AppState
    @InjectedObservable(\.navigationManager) var navigationManager
    
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker
    @Environment(OutdatedPackagesTracker.self) var outdatedPackagesTracker: OutdatedPackagesTracker

    var body: some View
    {
        NavigationLink(value: NavigationManager.DetailDestination.package(package: package))
        {
            PackageListItem(packageItem: package)
        }
        .contextMenu
        {
            SidebarContextMenu(package: package)
        }
        .modify
        { viewProxy in
            if enableSwipeActions
            {
                viewProxy
                    .swipeActions(edge: .leading, allowsFullSwipe: false)
                    {
                        TagUntagButton(package: package)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false)
                    {
                        PurgePackageButton(package: package)
                            .tint(.red)
                        
                        UninstallPackageButton(package: package)
                            .tint(.orange)
                    }
            }
            else
            {
                viewProxy
            }
        }
        .accessibilityAddTraits(.allowsDirectInteraction)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("Link to package")
        .accessibilityValue(package.name(withPrecision: .precise))
    }
}
