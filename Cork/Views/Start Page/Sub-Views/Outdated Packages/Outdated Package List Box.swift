//
//  Updater Box.swift
//  Cork
//
//  Created by David Bureš on 05.04.2023.
//

import SwiftUI
import Defaults
import CorkShared
import CorkModels

struct OutdatedPackageListBox: View
{    
    @Default(.displayOnlyIntentionallyInstalledPackagesByDefault) var displayOnlyIntentionallyInstalledPackagesByDefault: Bool
    
    @Default(.outdatedPackageInfoDisplayAmount) var outdatedPackageInfoDisplayAmount: OutdatedPackageInfoAmount

    @Environment(AppState.self) var appState: AppState
    @Environment(OutdatedPackagesTracker.self) var outdatedPackagesTracker: OutdatedPackagesTracker

    @Binding var isDropdownExpanded: Bool

    @State private var isSelfUpdatingSectionExpanded: Bool = false
    
    var body: some View
    {
        Grid
        {
            GridRow(alignment: .firstTextBaseline)
            {
                VStack(alignment: .leading)
                {
                    GroupBoxHeadlineGroupWithArbitraryContent(image: outdatedPackagesTracker.displayableOutdatedPackagesTracker.allDisplayableOutdatedPackages.count == 1 ? "square.and.arrow.down" : "square.and.arrow.down.on.square")
                    {
                        VStack(alignment: .leading, spacing: 5)
                        {
                            HStack(alignment: .firstTextBaseline)
                            {
                                Group
                                {
                                    switch outdatedPackagesTracker.outdatedPackageListBoxViewType {
                                    case .managedOnly, .bothManagedAndUnmanaged:
                                        Text("start-page.updates.count-\(outdatedPackagesTracker.displayableOutdatedPackagesTracker.allDisplayableOutdatedPackages.count)")
                                    case .unmanagedOnly:
                                        Text("start-page.updates.only-unmanaged.count-\(outdatedPackagesTracker.displayableOutdatedPackagesTracker.allDisplayableOutdatedPackages.count)")
                                    }
                                }
                                .font(.headline)

                                Spacer()

                                if outdatedPackagesTracker.displayableOutdatedPackagesTracker.areAllOutdatedPackagesMarkedForUpdating
                                {
                                    Button
                                    {
                                        appState.showSheet(ofType: .fullUpdate)
                                    } label: {
                                        Text("start-page.updates.action")
                                    }
                                    
                                    #if DEBUG
                                    // Text(String(packagesMarkedForUpdating.count))
                                    #endif
                                }
                                else
                                {
                                    Button
                                    {
                                        appState.showSheet(ofType: .partialUpdate(packagesToUpdate: outdatedPackagesTracker.displayableOutdatedPackagesTracker.packagesMarkedForUpdating))
                                    } label: {
                                        Text("start-page.update-incremental.package-count-\(outdatedPackagesTracker.displayableOutdatedPackagesTracker.packagesMarkedForUpdating.count)")
                                    }
                                    .disabled(outdatedPackagesTracker.displayableOutdatedPackagesTracker.packagesMarkedForUpdating.isEmpty)
                                }
                            }

                            DisclosureGroup(isExpanded: $isDropdownExpanded)
                            {
                                OutdatedPackagesList()
                                /*
                                switch outdatedPackageListBoxType
                                {
                                case .managedOnly:
                                    outdatedPackageListComplex(packagesToShow: packagesManagedByHomebrew)
                                case .unmanagedOnly:
                                    outdatedPackageListComplex(packagesToShow: packagesThatUpdateThemselves)
                                case .bothManagedAndUnmanaged:
                                    outdatedPackageListComplex(packagesToShow: packagesManagedByHomebrew)
                                    
                                    if !packagesThatUpdateThemselves.isEmpty
                                    {
                                        DisclosureGroup(isExpanded: $isSelfUpdatingSectionExpanded)
                                        {
                                            outdatedPackageListComplex(packagesToShow: packagesThatUpdateThemselves)
                                        } label: {
                                            Text("start-page.updates.self-updating.\(packagesThatUpdateThemselves.count).list")
                                                .font(.subheadline)
                                        }
                                    }
                                }
                                */
                            } label: {
                                // TODO: Fix this
                                /*
                                Group
                                {
                                    if outdatedPackageListBoxType == .unmanagedOnly
                                    {
                                        Text("start-page.updates.unmanaged-only.list")
                                    }
                                    else
                                    {
                                        Text("start-page.updates.list")
                                    }
                                }
                                 */
                                
                                Text("start-page.updates.list")
                            }
                            
                        }
                    }
                }
            }
        }
        .accessibilityLabel("accessibility.label.outdated-packages-box.listing-outdated-packages")
        .accessibilityValue("accessibility.value.listing-outdated-packages.\(outdatedPackagesTracker.displayableOutdatedPackagesTracker.packagesManagedByHomebrew.count)-managed.\(outdatedPackagesTracker.displayableOutdatedPackagesTracker.packagesThatUpdateThemselves.count)-unmanaged")
    }

    // MARK: - Outdated package list complex

    // MARK: - Outdated package list shared view builders

    @ViewBuilder
    var deselectAllButton: some View
    {
        Button
        {
            outdatedPackagesTracker.outdatedPackages = Set(outdatedPackagesTracker.outdatedPackages.map
            { modifiedElement in
                var copyOutdatedPackage: OutdatedPackage = modifiedElement
                if copyOutdatedPackage.id == modifiedElement.id
                {
                    copyOutdatedPackage.isMarkedForUpdating = false
                }
                return copyOutdatedPackage
            })
        } label: {
            Text("start-page.updated.action.deselect-all")
        }
        .disabled(outdatedPackagesTracker.displayableOutdatedPackagesTracker.packagesMarkedForUpdating.isEmpty)
        .modify
        { viewProxy in
            if outdatedPackageInfoDisplayAmount != .all
            {
                viewProxy
                    .buttonStyle(.accessoryBar)
            }
            else
            {
                viewProxy
            }
        }
    }

    @ViewBuilder
    var selectAllButton: some View
    {
        Button
        {
            outdatedPackagesTracker.outdatedPackages = Set(outdatedPackagesTracker.outdatedPackages.map
            { modifiedElement in
                var copyOutdatedPackage: OutdatedPackage = modifiedElement
                if copyOutdatedPackage.id == modifiedElement.id
                {
                    copyOutdatedPackage.isMarkedForUpdating = true
                }
                return copyOutdatedPackage
            })
        } label: {
            Text("start-page.updated.action.select-all")
        }
        .disabled(outdatedPackagesTracker.displayableOutdatedPackagesTracker.areAllOutdatedPackagesMarkedForUpdating)
        .modify
        { viewProxy in
            if outdatedPackageInfoDisplayAmount != .all
            {
                viewProxy
                    .buttonStyle(.accessoryBar)
            }
            else
            {
                viewProxy
            }
        }
    }

    // MARK: - Outdated package list view builders

    @ViewBuilder
    func outdatedPackageOverview_table(packagesToShow: Set<OutdatedPackage>) -> some View
    {
        VStack(alignment: .trailing)
        {
            Table(of: OutdatedPackage.self)
            {
                TableColumn("start-page.updates.action")
                { outdatedPackage in
                    Toggle(isOn: Binding<Bool>(
                        get: {
                            /// This was vibe-coded. It fixes the problem, but I have no idea why.
                            outdatedPackagesTracker.outdatedPackages.contains(where: { $0.id == outdatedPackage.id && $0.isMarkedForUpdating })
                        }, set: { toggleState in
                            outdatedPackagesTracker.outdatedPackages = Set(outdatedPackagesTracker.outdatedPackages.map
                            { modifiedElement in
                                var copyOutdatedPackage: OutdatedPackage = modifiedElement
                                if copyOutdatedPackage.id == outdatedPackage.id
                                {
                                    copyOutdatedPackage.isMarkedForUpdating = toggleState
                                }
                                return copyOutdatedPackage
                            })
                        }
                    ))
                    {
                        EmptyView()
                    }
                }
                .width(45)

                TableColumn("package-details.dependencies.results.name", value: \.package.name)

                TableColumn("start-page.updates.installed-version")
                { outdatedPackage in
                    Text(outdatedPackage.installedVersions.formatted(.list(type: .and)))
                }

                TableColumn("start-page.updates.newest-version")
                { outdatedPackage in
                    Text(outdatedPackage.newerVersion)
                }

                TableColumn("package-details.type")
                { outdatedPackage in
                    Text(outdatedPackage.package.type.description)
                }

            } rows: {
                ForEach(packagesToShow.sorted(by: { $0.package.installedOn! < $1.package.installedOn! }))
                { outdatedPackage in
                    TableRow(outdatedPackage)
                        .contextMenu
                        {
                            PreviewPackageButton(packageToPreview: .init(
                                name: outdatedPackage.package.name,
                                type: outdatedPackage.package.type,
                                installedIntentionally: outdatedPackage.package.installedIntentionally)
                            )
                        }
                }
            }
            .tableStyle(.bordered)

            HStack(alignment: .center)
            {
                deselectAllButton

                selectAllButton
            }
        }
    }
}
