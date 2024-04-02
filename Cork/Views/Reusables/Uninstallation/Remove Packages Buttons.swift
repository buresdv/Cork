//
//  Remove Packages Buttons.swift
//  Cork
//
//  Created by David Bureš on 02.04.2024.
//

import SwiftUI

struct UninstallPackageButton: View
{
    let package: BrewPackage
    
    let isCalledFromSidebar: Bool

    var body: some View
    {
        RemovePackageButton(package: package, shouldPurge: false, isCalledFromSidebar: isCalledFromSidebar)
    }
}

struct PurgePackageButton: View
{
    let package: BrewPackage
    
    let isCalledFromSidebar: Bool

    var body: some View
    {
        RemovePackageButton(package: package, shouldPurge: true, isCalledFromSidebar: isCalledFromSidebar)
    }
}

private struct RemovePackageButton: View
{
    @AppStorage("shouldRequestPackageRemovalConfirmation") var shouldRequestPackageRemovalConfirmation: Bool = false
    
    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker

    let package: BrewPackage

    let shouldPurge: Bool
    let isCalledFromSidebar: Bool
    
    @State private var isShowingPackageRemovalConfirmationDialog: Bool = false

    var body: some View
    {
        Button(role: .destructive)
        {
            if !shouldRequestPackageRemovalConfirmation
            {
                Task
                {
                    AppConstants.logger.debug("Confirmation of package removal NOT needed")
                    
                    try await uninstallSelectedPackage(
                        package: package,
                        brewData: brewData,
                        appState: appState,
                        outdatedPackageTracker: outdatedPackageTracker,
                        shouldRemoveAllAssociatedFiles: shouldPurge,
                        shouldApplyUninstallSpinnerToRelevantItemInSidebar: isCalledFromSidebar
                    )
                }
            }
            else
            {
                AppConstants.logger.debug("Confirmation of package removal needed")
                isShowingPackageRemovalConfirmationDialog = true
            }
        } label: {
            Text(shouldPurge ? "action.purge-\(package.name)" : "action.uninstall-\(package.name)")
        }
        .confirmationDialog(shouldPurge ? "action.purge.confirm.title.\(package.name)" : "action.uninstall.confirm.title.\(package.name)", isPresented: $isShowingPackageRemovalConfirmationDialog) {
            Button(role: .destructive)
            {
                Task
                {
                    try await uninstallSelectedPackage(
                        package: package,
                        brewData: brewData,
                        appState: appState,
                        outdatedPackageTracker: outdatedPackageTracker,
                        shouldRemoveAllAssociatedFiles: shouldPurge,
                        shouldApplyUninstallSpinnerToRelevantItemInSidebar: isCalledFromSidebar
                    )
                }
            } label: {
                Text(shouldPurge ? "action.purge-\(package.name)" : "action.uninstall-\(package.name)")
            }
            .keyboardShortcut(.defaultAction)
            
            Button(role: .cancel)
            {
                isShowingPackageRemovalConfirmationDialog = false
            } label: {
                Text("action.cancel")
            }
            .keyboardShortcut(.cancelAction)
        } message: {
            Text("action.warning.cannot-be-undone")
        }

    }
}
