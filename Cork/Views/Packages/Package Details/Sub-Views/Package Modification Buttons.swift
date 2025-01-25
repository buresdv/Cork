//
//  Package Modification Buttons.swift
//  Cork
//
//  Created by David Bureš on 03.10.2023.
//

import SwiftUI
import CorkShared
import ButtonKit

struct PackageModificationButtons: View
{
    @AppStorage("allowMoreCompleteUninstallations") var allowMoreCompleteUninstallations: Bool = false
    @AppStorage("shouldRequestPackageRemovalConfirmation") var shouldRequestPackageRemovalConfirmation: Bool = false

    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker
    @EnvironmentObject var uninstallationConfirmationTracker: UninstallationConfirmationTracker

    let package: BrewPackage
    @ObservedObject var packageDetails: BrewPackageDetails

    let isLoadingDetails: Bool

    var body: some View
    {
        if package.installedOn != nil // Only show the uninstall button for packages that are actually installed
        {
            if !isLoadingDetails
            {
                ButtonBottomRow
                {
                    if package.type == .formula
                    {
                        AsyncButton
                        {
                            do
                            {
                                try await packageDetails.changePinnedStatus()
                            }
                            catch let pinningUnpinningError
                            {
                                AppConstants.shared.logger.error("Failed while pinning/unpinning package \(package.name): \(pinningUnpinningError)")
                            }
                        } label: {
                            Text(packageDetails.pinned ? "package-details.action.unpin-version-\(package.versions.formatted(.list(type: .and)))" : "package-details.action.pin-version-\(package.versions.formatted(.list(type: .and)))")
                        }
                        .asyncButtonStyle(.leading)
                        .disabledWhenLoading()
                    }

                    Spacer()

                    HStack(spacing: 15)
                    {
                        UninstallationProgressWheel()

                        if allowMoreCompleteUninstallations
                        {
                            Spacer()
                        }

                        if !allowMoreCompleteUninstallations
                        {
                            UninstallPackageButton(package: package, isCalledFromSidebar: false)
                        }
                        else
                        {
                            Menu
                            {
                                PurgePackageButton(package: package, isCalledFromSidebar: false)
                            } label: {
                                Text("action.uninstall-\(package.name)")
                            } primaryAction: {
                                // TODO: This is a duplicate of the logic already present in RemovePackageButton. Find a way to merge them.
                                if !shouldRequestPackageRemovalConfirmation
                                {
                                    Task
                                    {
                                        AppConstants.shared.logger.debug("Confirmation of package removal NOT needed")

                                        try await brewData.uninstallSelectedPackage(
                                            package: package,
                                            appState: appState,
                                            outdatedPackageTracker: outdatedPackageTracker,
                                            shouldRemoveAllAssociatedFiles: false,
                                            shouldApplyUninstallSpinnerToRelevantItemInSidebar: false
                                        )
                                    }
                                }
                                else
                                {
                                    AppConstants.shared.logger.debug("Confirmation of package removal needed")
                                    uninstallationConfirmationTracker.showConfirmationDialog(packageThatNeedsConfirmation: package, shouldPurge: false, isCalledFromSidebar: false)
                                }
                            }
                            .fixedSize()
                        }
                    }
                }
            }
        }
    }
}
