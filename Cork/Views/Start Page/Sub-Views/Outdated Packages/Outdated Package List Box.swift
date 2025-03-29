//
//  Updater Box.swift
//  Cork
//
//  Created by David Bureš on 05.04.2023.
//

import SwiftUI

struct OutdatedPackageListBox: View
{
    enum OutdatedPackageListBoxViewType
    {
        /// Only packages that are managed by Homerbew are outdated
        case managedOnly
        
        /// Both packages that are managed by Homebrew, and those that are not (available only through the `--greedy` flag) are available
        case bothManagedAndUnmanaged
        
        /// Only unmanaged packages (available only through the `--greedy` flag) are availabe
        case unmanagedOnly
    }
    
    @AppStorage("displayOnlyIntentionallyInstalledPackagesByDefault") var displayOnlyIntentionallyInstalledPackagesByDefault: Bool = true
    @AppStorage("outdatedPackageInfoDisplayAmount") var outdatedPackageInfoDisplayAmount: OutdatedPackageInfoAmount = .versionOnly

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker

    @Binding var isDropdownExpanded: Bool

    @State private var isSelfUpdatingSectionExpanded: Bool = false

    private var packagesMarkedForUpdating: [OutdatedPackage]
    {
        return outdatedPackageTracker.displayableOutdatedPackages.filter { $0.isMarkedForUpdating }
    }

    private var packagesManagedByHomebrew: Set<OutdatedPackage>
    {
        return outdatedPackageTracker.displayableOutdatedPackages.filter { $0.updatingManagedBy == .homebrew }
    }

    private var packagesThatUpdateThemselves: Set<OutdatedPackage>
    {
        return outdatedPackageTracker.displayableOutdatedPackages.filter { $0.updatingManagedBy == .selfUpdating }
    }

    private var outdatedPackageListBoxType: OutdatedPackageListBoxViewType
    {
        if !packagesManagedByHomebrew.isEmpty && !packagesThatUpdateThemselves.isEmpty
        { /// Managed packages are not empty, unmanaged packages are not empty
            return .bothManagedAndUnmanaged
        }
        else if packagesManagedByHomebrew.isEmpty && !packagesThatUpdateThemselves.isEmpty
        { /// Managed packages are empty, unmanaged packages are not empty
            return .unmanagedOnly
        }
        else
        {
            return .managedOnly
        }
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
                                Group
                                {
                                    if packagesManagedByHomebrew.isEmpty && !packagesThatUpdateThemselves.isEmpty
                                    { /// If the only outdated packages are those that update themselves, show a special message
                                        Text("start-page.updates.only-unmanaged.count-\(outdatedPackageTracker.displayableOutdatedPackages.count)")
                                    }
                                    else
                                    { /// Otherwise, show the standard message
                                        Text("start-page.updates.count-\(outdatedPackageTracker.displayableOutdatedPackages.count)")
                                    }
                                }
                                .font(.headline)

                                Spacer()

                                if packagesMarkedForUpdating.count == outdatedPackageTracker.displayableOutdatedPackages.count
                                {
                                    Button
                                    {
                                        appState.showSheet(ofType: .fullUpdate)
                                    } label: {
                                        Text("start-page.updates.action")
                                    }
                                    
                                    #if DEBUG
                                    Text(String(packagesMarkedForUpdating.count))
                                    #endif
                                }
                                else
                                {
                                    Button
                                    {
                                        appState.showSheet(ofType: .partialUpdate)
                                    } label: {
                                        Text("start-page.update-incremental.package-count-\(packagesMarkedForUpdating.count)")
                                    }
                                    .disabled(packagesMarkedForUpdating.isEmpty)
                                }
                            }

                            DisclosureGroup(isExpanded: $isDropdownExpanded)
                            {
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

                            } label: {
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
                                .font(.subheadline)
                            }
                            
                        }
                    }
                }
            }
        }
    }

    // MARK: - Outdated package list complex

    @ViewBuilder
    func outdatedPackageListComplex(packagesToShow: Set<OutdatedPackage>) -> some View
    {
        if packagesToShow.isEmpty
        {
            Text("update-packages.no-managed-updates")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        else
        {
            if outdatedPackageInfoDisplayAmount != .all
            {
                outdatedPackageOverview_list(packagesToShow: packagesToShow)
            }
            else
            {
                outdatedPackageOverview_table(packagesToShow: packagesToShow)
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
    func outdatedPackageOverview_list(packagesToShow: Set<OutdatedPackage>) -> some View
    {
        List
        {
            Section
            {
                ForEach(packagesToShow.sorted(by: { $0.package.installedOn! < $1.package.installedOn! }))
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
                            .contextMenu
                            {
                                PreviewPackageButton(packageNameToPreview: outdatedPackage.package.name)
                            }
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
                            outdatedPackageTracker.outdatedPackages.contains(where: { $0.id == outdatedPackage.id && $0.isMarkedForUpdating })
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
                            PreviewPackageButton(packageNameToPreview: outdatedPackage.package.name)
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
                let installedVersions: String = outdatedPackage.installedVersions.formatted(.list(type: .and))
                let newerVersion: String = outdatedPackage.newerVersion
                
                let pillForegroundColor: NSColor = .secondaryLabelColor
                let pillBackgroundColor: NSColor = .quinaryLabel
                
                if showOldVersionsInOutdatedPackageList
                {
                    
                    PillText(text: "\(installedVersions) → \(newerVersion)", backgroundColor: pillBackgroundColor, textColor: pillForegroundColor)
                }
                else
                {
                    PillText(text: "\(newerVersion)", backgroundColor: pillBackgroundColor, textColor: pillForegroundColor)
                }
            }
        }
    }
}
