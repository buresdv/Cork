//
//  Sidebar Package Row.swift
//  Cork
//
//  Created by Seb Jachec on 08/09/2023.
//

import SwiftUI

struct SidebarPackageRow: View
{
    let package: BrewPackage

    @AppStorage("allowMoreCompleteUninstallations") var allowMoreCompleteUninstallations: Bool = false

    @AppStorage("enableRevealInFinder") var enableRevealInFinder: Bool = false

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker

    var body: some View
    {
        NavigationLink(value: package)
        {
            PackageListItem(packageItem: package)
        }
        .contextMenu
        {
            contextMenuContent
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false)
        {
            tagUntagButton
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false)
        {
            UninstallPackageButton(package: package, isCalledFromSidebar: true)
                .tint(.orange)
            
            PurgePackageButton(package: package, isCalledFromSidebar: true)
                .tint(.red)
        }
    }

    @ViewBuilder
    var tagUntagButton: some View
    {
        Button
        {
            Task(priority: .userInitiated)
            {
                await changePackageTagStatus(
                    package: package,
                    brewData: brewData,
                    appState: appState
                )
            }
        } label: {
            Label(package.isTagged ? "sidebar.section.all.contextmenu.untag-\(package.name)" : "sidebar.section.all.contextmenu.tag-\(package.name)", systemImage: package.isTagged ? "tag.slash" : "tag")
        }
    }
    
    @ViewBuilder
    var contextMenuContent: some View
    {
        tagUntagButton
        
        Divider()

        UninstallPackageButton(package: package, isCalledFromSidebar: true)

        if allowMoreCompleteUninstallations
        {
            PurgePackageButton(package: package, isCalledFromSidebar: true)
        }

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
