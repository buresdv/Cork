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

    @AppStorage("enableRevealInFinder") var enableRevealInFinder: Bool = false
    @AppStorage("enableSwipeActions") var enableSwipeActions: Bool = false

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
        .modify
        { viewProxy in
            if enableSwipeActions
            {
                viewProxy
                    .swipeActions(edge: .leading, allowsFullSwipe: false)
                    {
                        tagUntagButton
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

    @ViewBuilder
    var tagUntagButton: some View
    {
        Button
        {
            changeTaggedStatus()
        } label: {
            Label(package.isTagged ? "sidebar.section.all.contextmenu.untag-\(package.name)" : "sidebar.section.all.contextmenu.tag-\(package.name)", systemImage: package.isTagged ? "tag.slash" : "tag")
        }
    }

    @ViewBuilder
    var contextMenuContent: some View
    {
        tagUntagButton

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
    
    func changeTaggedStatus()
    {
        AppConstants.shared.logger.info("Will change tagged status of \(package.name). Current state of the tagged package tracker: \(appState.taggedPackageNames)")
        
        brewData.updatePackageInPlace(package)
        { package in
            package.changeTaggedStatus()
        }
        
        if package.isTagged
        {
            AppConstants.shared.logger.info("Tagged package tracker DOES contain \(package.name). Will remove")
            appState.taggedPackageNames.remove(package.name)
        }
        else
        {
            AppConstants.shared.logger.info("Tagged package tracker does NOT contain \(package.name). Will insert")
            appState.taggedPackageNames.insert(package.name)
        }
        
    }
}
