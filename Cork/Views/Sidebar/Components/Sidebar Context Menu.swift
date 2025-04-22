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
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var brewData: BrewDataStorage
    
    @AppStorage("enableRevealInFinder") var enableRevealInFinder: Bool = false
    
    let package: BrewPackage
    
    var body: some View
    {
        TagUntagButton(package: package)

        Divider()

        UninstallPackageButton(package: package, isCalledFromSidebar: true)

        PurgePackageButton(package: package, isCalledFromSidebar: true)

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
