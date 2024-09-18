//
//  Updater Box.swift
//  Cork
//
//  Created by David Bureš on 05.04.2023.
//

import SwiftUI

struct OutdatedPackageListBox: View
{
    @AppStorage("displayOnlyIntentionallyInstalledPackagesByDefault") var displayOnlyIntentionallyInstalledPackagesByDefault: Bool = true
    @AppStorage("outdatedPackageInfoDisplayAmount") var outdatedPackageInfoDisplayAmount: OutdatedPackageInfoAmount = .versionOnly

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker

    @Binding var isDropdownExpanded: Bool

    private var packagesMarkedForUpdating: [OutdatedPackage]
    {
        return outdatedPackageTracker.displayableOutdatedPackages.filter { $0.isMarkedForUpdating }
    }

    var body: some View
    {
        Grid
        {
            GridRow(alignment: .firstTextBaseline)
            {
                VStack(alignment: .leading)
                {
                    GroupBoxHeadlineGroupWithArbitraryContent(image: outdatedPackageTracker.displayableOutdatedPackages.count == 1 ? "square.and.arrow.down" : "square.and.arrow.down.on.square")
                    {
                        VStack(alignment: .leading, spacing: 5)
                        {
                            HStack(alignment: .firstTextBaseline)
                            {
                                Text("start-page.updates.count-\(outdatedPackageTracker.displayableOutdatedPackages.count)")
                                    .font(.headline)

                                Spacer()

                                if packagesMarkedForUpdating.count == outdatedPackageTracker.displayableOutdatedPackages.count
                                {
                                    Button
                                    {
                                        appState.isShowingUpdateSheet = true
                                    } label: {
                                        Text("start-page.updates.action")
                                    }
                                }
                                else
                                {
                                    Button
                                    {
                                        appState.isShowingIncrementalUpdateSheet = true
                                    } label: {
                                        Text("start-page.update-incremental.package-count-\(packagesMarkedForUpdating.count)")
                                    }
                                    .disabled(packagesMarkedForUpdating.isEmpty)
                                }
                            }

                            DisclosureGroup(isExpanded: $isDropdownExpanded)
                            {
                                if outdatedPackageInfoDisplayAmount != .all
                                {
                                    outdatedPackageOverview_list
                                }
                                else
                                {
                                    outdatedPackageOverview_table
                                }
                            } label: {
                                Text("start-page.updates.list")
                                    .font(.subheadline)
                            }
                            .disclosureGroupStyle(NoPadding())
                        }
                    }
                }
            }
        }
    }

    // MARK: - Outdated package list shared view builders

    @ViewBuilder
    var deselectAllButton: some View
    {
        Button
        {
            outdatedPackageTracker.outdatedPackages = Set(outdatedPackageTracker.outdatedPackages.map
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
        .disabled(packagesMarkedForUpdating.isEmpty)
        .modify
        { viewProxy in
            if outdatedPackageInfoDisplayAmount != .all
            {
                viewProxy
                    .buttonStyle(.plain)
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
            outdatedPackageTracker.outdatedPackages = Set(outdatedPackageTracker.outdatedPackages.map
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
        .disabled(packagesMarkedForUpdating.count == outdatedPackageTracker.displayableOutdatedPackages.count)
        .modify
        { viewProxy in
            if outdatedPackageInfoDisplayAmount != .all
            {
                viewProxy
                    .buttonStyle(.plain)
            }
            else
            {
                viewProxy
            }
        }
    }

    // MARK: - Outdated package list view builders

    @ViewBuilder
    var outdatedPackageOverview_list: some View
    {
        List
        {
            Section
            {
                ForEach(outdatedPackageTracker.displayableOutdatedPackages.sorted(by: { $0.package.installedOn! < $1.package.installedOn! }))
                { outdatedPackage in
                    Toggle(isOn: Binding<Bool>(
                        get: {
                            outdatedPackage.isMarkedForUpdating
                        }, set: { toggleState in
                            outdatedPackageTracker.outdatedPackages = Set(outdatedPackageTracker.outdatedPackages.map
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
                        OutdatedPackageListBoxRow(outdatedPackage: outdatedPackage)
                    }
                }
            } header: {
                HStack(alignment: .center, spacing: 10)
                {
                    deselectAllButton

                    selectAllButton
                }
            }
        }
        .listStyle(.bordered(alternatesRowBackgrounds: true))
    }

    @ViewBuilder
    var outdatedPackageOverview_table: some View
    {
        VStack(alignment: .trailing)
        {
            Table(of: OutdatedPackage.self)
            {
                TableColumn("start-page.updates.action")
                { outdatedPackage in
                    Toggle(isOn: Binding<Bool>(
                        get: {
                            outdatedPackage.isMarkedForUpdating
                        }, set: { toggleState in
                            outdatedPackageTracker.outdatedPackages = Set(outdatedPackageTracker.outdatedPackages.map
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
                        .foregroundColor(.orange)
                }
                
                TableColumn("start-page.updates.newest-version")
                { outdatedPackage in
                    Text(outdatedPackage.newerVersion)
                        .foregroundColor(.blue)
                }
                
                TableColumn("package-details.type")
                { outdatedPackage in
                    Text(outdatedPackage.package.type.description)
                }
                
            } rows: {
                ForEach(outdatedPackageTracker.displayableOutdatedPackages.sorted(by: { $0.package.installedOn! < $1.package.installedOn! }))
                { outdatedPackage in
                    TableRow(outdatedPackage)
                        .contextMenu {
                            PreviewPackageButton(packageNameToPreview: outdatedPackage.package.name)
                        }

                }
            }

            HStack(alignment: .center)
            {
                deselectAllButton

                selectAllButton
            }
        }
    }
}

// MARK: - List row

private struct OutdatedPackageListBoxRow: View
{
    @AppStorage("outdatedPackageInfoDisplayAmount") var outdatedPackageInfoDisplayAmount: OutdatedPackageInfoAmount = .versionOnly
    @AppStorage("showOldVersionsInOutdatedPackageList") var showOldVersionsInOutdatedPackageList: Bool = true

    let outdatedPackage: OutdatedPackage

    @State private var isExpanded: Bool = false

    var body: some View
    {
        VStack(alignment: .leading)
        {
            switch outdatedPackageInfoDisplayAmount
            {
            case .none:
                outdatedPackageDetails_none
            case .versionOnly:
                outdatedPackageDetails_versionOnly
            case .all:
                EmptyView()
            }
        }
    }

    // MARK: - Various types of outdated package displays

    @ViewBuilder
    var outdatedPackageDetails_none: some View
    {
        SanitizedPackageName(packageName: outdatedPackage.package.name, shouldShowVersion: true)
    }

    @ViewBuilder
    var outdatedPackageDetails_versionOnly: some View
    {
        HStack(alignment: .center)
        {
            SanitizedPackageName(packageName: outdatedPackage.package.name, shouldShowVersion: true)

            HStack(alignment: .center)
            {
                if showOldVersionsInOutdatedPackageList
                {
                    OutlinedPill(content: {
                        Text(outdatedPackage.installedVersions.formatted(.list(type: .and)))
                    }, color: .orange)

                    Text("→")
                        .foregroundColor(.secondary)
                }

                OutlinedPill(content: {
                    Text(outdatedPackage.newerVersion)
                }, color: .blue)
            }
        }
    }
}
