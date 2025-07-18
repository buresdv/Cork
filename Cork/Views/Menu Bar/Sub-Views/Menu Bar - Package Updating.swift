//
//  Menu Bar - Package Updating.swift
//  Cork
//
//  Created by David Bureš on 30.03.2024.
//

import SwiftUI

struct MenuBar_PackageUpdating: View
{
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker

    var body: some View
    {
        if outdatedPackageTracker.isCheckingForPackageUpdates
        {
            Text("start-page.updates.loading")
                .disabled(true)
        }
        else
        {
            if !outdatedPackageTracker.displayableOutdatedPackages.isEmpty
            {
                if let sanitizedSheetState = appState.sheetToShow
                {
                    if sanitizedSheetState != .fullUpdate || sanitizedSheetState != .partialUpdate(packagesToUpdate: .init())
                    {
                        Menu
                        {
                            ForEach(outdatedPackageTracker.displayableOutdatedPackages.sorted(by: { $0.package.installedOn! < $1.package.installedOn! }))
                            { outdatedPackage in
                                SanitizedPackageName(package: outdatedPackage.package, shouldShowVersion: false)
                            }
                        } label: {
                            Text("notification.outdated-packages-found.body-\(outdatedPackageTracker.displayableOutdatedPackages.count)")
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
