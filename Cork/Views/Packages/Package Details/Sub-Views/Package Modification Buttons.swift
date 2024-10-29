//
//  Package Modification Buttons.swift
//  Cork
//
//  Created by David Bureš on 03.10.2023.
//

import SwiftUI
import CorkShared

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

    @State private var isPinning: Bool = false

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
                        Button
                        {
                            Task
                            {
                                withAnimation
                                {
                                    isPinning = true
                                }

                                defer
                                {
                                    withAnimation
                                    {
                                        isPinning = false
                                    }
                                }

                                do
                                {
                                    try await packageDetails.changePinnedStatus()
                                }
                                catch let pinningUnpinningError
                                {
                                    AppConstants.shared.logger.error("Failed while pinning/unpinning package \(package.name): \(pinningUnpinningError)")
                                }
                            }
                        } label: {
                            HStack(alignment: .center, spacing: 5)
                            {
                                if isPinning
                                {
                                    ProgressView()
                                        .controlSize(.mini)
                                        .transition(.move(edge: .leading).combined(with: .opacity))
                                }
                                Text(packageDetails.pinned ? "package-details.action.unpin-version-\(package.versions.formatted(.list(type: .and)))" : "package-details.action.pin-version-\(package.versions.formatted(.list(type: .and)))")
                            }
                        }
                        .disabled(isPinning)
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
                            .disabled(isPinning)
                        }
                    }
                }
            }
        }
    }
}
