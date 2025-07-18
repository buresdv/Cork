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
    @EnvironmentObject var cachedPackagesTracker: CachedPackagesTracker
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker

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
                        PinUnpinButton(package: package)
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
                            UninstallPackageButton(package: package)
                        }
                        else
                        {
                            Menu
                            {
                                PurgePackageButton(package: package)
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
                                            cachedPackagesTracker: cachedPackagesTracker,
                                            appState: appState,
                                            outdatedPackageTracker: outdatedPackageTracker,
                                            shouldRemoveAllAssociatedFiles: false
                                        )
                                    }
                                }
                                else
                                {
                                    AppConstants.shared.logger.debug("Confirmation of package removal needed")
                                    appState.showConfirmationDialog(ofType: .uninstallPackage(package))
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
