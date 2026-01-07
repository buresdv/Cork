//
//  Menu Bar - Package Updating.swift
//  Cork
//
//  Created by David Bureš on 30.03.2024.
//

import SwiftUI
import CorkModels

struct MenuBar_PackageUpdating: View
{
    @Environment(AppState.self) var appState: AppState
    @Environment(OutdatedPackagesTracker.self) var outdatedPackagesTracker: OutdatedPackagesTracker

    var body: some View
    {
        if outdatedPackagesTracker.isCheckingForPackageUpdates
        {
            Text("start-page.updates.loading")
                .disabled(true)
        }
        else
        {
            if !outdatedPackagesTracker.allDisplayableOutdatedPackages.isEmpty
            {
                if let sanitizedSheetState = appState.sheetToShow
                {
                    if sanitizedSheetState != .fullUpdate || sanitizedSheetState != .partialUpdate(packagesToUpdate: .init())
                    {
                        Menu
                        {
                            ForEach(outdatedPackagesTracker.allDisplayableOutdatedPackages.sorted(by: { $0.package.installedOn! < $1.package.installedOn! }))
                            { outdatedPackage in
                                SanitizedPackageName(package: outdatedPackage.package, shouldShowVersion: false)
                            }
                        } label: {
                            Text("notification.outdated-packages-found.body-\(outdatedPackagesTracker.allDisplayableOutdatedPackages.count)")
                        }
                        
                        Button("navigation.upgrade-packages")
                        {
                            switchCorkToForeground()
                            appState.showSheet(ofType: .fullUpdate)
                        }
                    }
                    else
                    {
                        Text("update-packages.detail-stage.pouring")
                    }
                }
                else
                {
                    Text("update-packages.detail-stage.pouring")
                }
                
            }
            else
            {
                Text("update-packages.no-updates.description")
            }
        }
    }
}
