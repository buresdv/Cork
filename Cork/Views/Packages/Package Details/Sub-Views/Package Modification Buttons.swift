//
//  Package Modification Buttons.swift
//  Cork
//
//  Created by David Bureš on 03.10.2023.
//

import SwiftUI

struct PackageModificationButtons: View
{
    @AppStorage("allowMoreCompleteUninstallations") var allowMoreCompleteUninstallations: Bool = false

    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker

    let package: BrewPackage

    @Binding var pinned: Bool
    @State private var isShowingUninstallConfirmation = false
    @State private var removeAllAssociatedFiles = false

    let isLoadingDetails: Bool

    var body: some View
    {
        if let _ = package.installedOn // Only show the uninstall button for packages that are actually installed
        {
            if !isLoadingDetails
            {
                ButtonBottomRow
                {
                    if !package.isCask
                    {
                        Button
                        {
                            Task
                            {
                                pinned.toggle()

                                await pinAndUnpinPackage(package: package, pinned: pinned)
                            }
                        } label: {
                            Text(pinned ? "package-details.action.unpin-version-\(package.versions.formatted(.list(type: .and)))" : "package-details.action.pin-version-\(package.versions.formatted(.list(type: .and)))")
                        }
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
                            Button
                            {
                                isShowingUninstallConfirmation = true
                                removeAllAssociatedFiles = false
                            } label: {
                                Text("package-details.action.uninstall-\(package.name)")
                            }
                            .confirmationDialog(
                                Text("package-details.action.uninstall-\(package.name)"),
                                isPresented: $isShowingUninstallConfirmation
                            )
                            {
                                Button(role: .destructive)
                                {
                                    Task(priority: .userInitiated)
                                    {
                                        try await uninstallSelectedPackage(
                                            package: package,
                                            brewData: brewData,
                                            appState: appState,
                                            outdatedPackageTracker: outdatedPackageTracker,
                                            shouldRemoveAllAssociatedFiles: removeAllAssociatedFiles
                                        )
                                    }
                                } label: {
                                    Text("package-details.action.uninstall-\("")")
                                }
                            } message: {
                                Text("package-details.action.uninstall.message-\(package.name)")
                            }
                            .dialogIcon(Image(systemName: "trash.circle.fill"))
                        }
                        else
                        {
                            Menu
                            {
                                Button
                                {
                                    isShowingUninstallConfirmation = true
                                    removeAllAssociatedFiles = true
                                } label: {
                                    Text("package-details.action.uninstall-deep-\(package.name)")
                                }
                            } label: {
                                Text("package-details.action.uninstall-\(package.name)")
                            } primaryAction: {
                                isShowingUninstallConfirmation = true
                                removeAllAssociatedFiles = false
                            }
                            .fixedSize()
                            .confirmationDialog(
                                Text(removeAllAssociatedFiles ?
                                    "package-details.action.uninstall-deep-\(package.name)" :
                                    "package-details.action.uninstall-\(package.name)"),
                                isPresented: $isShowingUninstallConfirmation
                            )
                            {
                                Button(role: .destructive)
                                {
                                    Task(priority: .userInitiated)
                                    {
                                        try await uninstallSelectedPackage(
                                            package: package,
                                            brewData: brewData,
                                            appState: appState,
                                            outdatedPackageTracker: outdatedPackageTracker,
                                            shouldRemoveAllAssociatedFiles: removeAllAssociatedFiles
                                        )
                                    }
                                } label: {
                                    Text(removeAllAssociatedFiles ?
                                        "package-details.action.uninstall-deep-\("")" :
                                        "package-details.action.uninstall-\("")")
                                }
                            } message: {
                                Text(removeAllAssociatedFiles ?
                                    "package-details.action.uninstall-deep.message-\(package.name)" :
                                    "package-details.action.uninstall.message-\(package.name)")
                            }
                            .dialogIcon(Image(systemName: "trash.circle.fill"))
                        }
                    }
                }
            }
        }
    }
}
