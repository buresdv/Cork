//
//  Remove Packages Buttons.swift
//  Cork
//
//  Created by David Bureš on 02.04.2024.
//

import SwiftUI
import CorkShared
import ButtonKit
import Defaults

/// Button for uninstalling packages
struct UninstallPackageButton: View
{
    let package: BrewPackage

    var body: some View
    {
        RemovePackageButton(package: package, shouldPurge: false)
    }
}

/// Button for purging packages
/// Will not display when purging is disabled
struct PurgePackageButton: View
{
    @Default(.allowMoreCompleteUninstallations) var allowMoreCompleteUninstallations: Bool
    
    let package: BrewPackage

    var body: some View
    {
        if allowMoreCompleteUninstallations
        {
            RemovePackageButton(package: package, shouldPurge: true)
        }
    }
}

private struct RemovePackageButton: View
{
    @Default(.shouldRequestPackageRemovalConfirmation) var shouldRequestPackageRemovalConfirmation: Bool

    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker
    @Environment(AppState.self) var appState: AppState
    @Environment(OutdatedPackagesTracker.self) var outdatedPackagesTracker: OutdatedPackagesTracker
    @Environment(CachedDownloadsTracker.self) var cachedDownloadsTracker: CachedDownloadsTracker

    var package: BrewPackage

    let shouldPurge: Bool

    var body: some View
    {
        AsyncButton(role: .destructive)
        {
            if !shouldRequestPackageRemovalConfirmation
            {
                AppConstants.shared.logger.debug("Confirmation of package removal NOT needed")

                try await brewPackagesTracker.uninstallSelectedPackage(
                    package: package,
                    cachedDownloadsTracker: cachedDownloadsTracker,
                    appState: appState,
                    outdatedPackagesTracker: outdatedPackagesTracker,
                    shouldRemoveAllAssociatedFiles: shouldPurge
                )
            }
            else
            {
                AppConstants.shared.logger.debug("Confirmation of package removal needed")
                
                if !shouldPurge
                {
                    appState.showConfirmationDialog(ofType: .uninstallPackage(package))
                } else {
                    appState.showConfirmationDialog(ofType: .purgePackage(package))
                }
            }
        } label: {
            if shouldPurge
            {
                Label {
                    Text("action.purge-\(package.name)")
                } icon: {
                    Image("custom.trash.triangle.fill")
                }
            }
            else
            {
                Label("action.uninstall-\(package.name)", systemImage: "trash")
            }
        }
    }
}
