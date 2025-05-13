//
//  Sidebar Package Row.swift
//  Cork
//
//  Created by Seb Jachec on 08/09/2023.
//

import CorkShared
import SwiftUI

struct SidebarPackageRow: View
{
    let package: BrewPackage

    @AppStorage("enableSwipeActions") var enableSwipeActions: Bool = false

    @Environment(AppState.self) var appState: AppState
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker

    var body: some View
    {
        NavigationLink(value: package)
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
    }
}
