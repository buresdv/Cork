//
//  Remove Packages Buttons.swift
//  Cork
//
//  Created by David Bureš on 02.04.2024.
//

import SwiftUI
import CorkShared
import ButtonKit

/// Button for uninstalling packages
struct UninstallPackageButton: View
{
    let package: BrewPackage

    let isCalledFromSidebar: Bool

    var body: some View
    {
        RemovePackageButton(package: package, shouldPurge: false, isCalledFromSidebar: isCalledFromSidebar)
    }
}

/// Button for purging packages
/// Will not display when purging is disabled
struct PurgePackageButton: View
{
    @AppStorage("allowMoreCompleteUninstallations") var allowMoreCompleteUninstallations: Bool = false
    
    let package: BrewPackage

    let isCalledFromSidebar: Bool

    var body: some View
    {
        if allowMoreCompleteUninstallations
        {
            RemovePackageButton(package: package, shouldPurge: true, isCalledFromSidebar: isCalledFromSidebar)
        }
    }
}

private struct RemovePackageButton: View
{
    @AppStorage("shouldRequestPackageRemovalConfirmation") var shouldRequestPackageRemovalConfirmation: Bool = false

    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker

    @EnvironmentObject var uninstallationConfirmationTracker: UninstallationConfirmationTracker

    var package: BrewPackage

    let shouldPurge: Bool
    let isCalledFromSidebar: Bool

    var body: some View
    {
        AsyncButton(role: .destructive)
        {
            if !shouldRequestPackageRemovalConfirmation
            {
                AppConstants.shared.logger.debug("Confirmation of package removal NOT needed")

                try await brewData.uninstallSelectedPackage(
                    package: package,
                    appState: appState,
                    outdatedPackageTracker: outdatedPackageTracker,
                    shouldRemoveAllAssociatedFiles: shouldPurge,
                    shouldApplyUninstallSpinnerToRelevantItemInSidebar: isCalledFromSidebar
                )
            }
            else
            {
                AppConstants.shared.logger.debug("Confirmation of package removal needed")
                uninstallationConfirmationTracker.showConfirmationDialog(packageThatNeedsConfirmation: package, shouldPurge: shouldPurge, isCalledFromSidebar: isCalledFromSidebar)
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
