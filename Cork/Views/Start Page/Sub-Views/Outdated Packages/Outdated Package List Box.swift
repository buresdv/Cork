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
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker

    @Binding var isDropdownExpanded: Bool

    private var packagesMarkedForUpdating: [OutdatedPackage]
    {
        return outdatedPackageTracker.outdatedPackages.filter({ $0.isMarkedForUpdating })
    }

    var body: some View
    {
        Grid
        {
            GridRow(alignment: .firstTextBaseline)
            {
                VStack(alignment: .leading)
                {
                    GroupBoxHeadlineGroupWithArbitraryContent(image: outdatedPackageTracker.outdatedPackages.count == 1 ? "square.and.arrow.down" : "square.and.arrow.down.on.square")
                    {
                        VStack(alignment: .leading, spacing: 5)
                        {
                            HStack(alignment: .firstTextBaseline)
                            {
                                Text("start-page.updates.count-\(outdatedPackageTracker.outdatedPackages.count)")
                                    .font(.headline)

                                Spacer()

                                if packagesMarkedForUpdating.count == outdatedPackageTracker.outdatedPackages.count
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
                                    .disabled(packagesMarkedForUpdating.count == 0)
                                }
                            }

                            DisclosureGroup(isExpanded: $isDropdownExpanded)
                            {
                                List
                                {
                                    Section
                                    {
                                        ForEach(outdatedPackageTracker.outdatedPackages.sorted(by: { $0.package.installedOn! < $1.package.installedOn! }))
                                        { outdatedPackage in
                                            Toggle(isOn: Binding<Bool>(
                                                get: {
                                                    outdatedPackage.isMarkedForUpdating
                                                }, set: { toggleState in
                                                    outdatedPackageTracker.outdatedPackages = Set(outdatedPackageTracker.outdatedPackages.map({ modifiedElement in
                                                        var copyOutdatedPackage = modifiedElement
                                                        if copyOutdatedPackage.id == outdatedPackage.id
                                                        {
                                                            copyOutdatedPackage.isMarkedForUpdating = toggleState
                                                        }
                                                        return copyOutdatedPackage
                                                    }))
                                                }
                                            )) {
                                                SanitizedPackageName(packageName: outdatedPackage.package.name, shouldShowVersion: true)
                                            }
                                        }
                                    } header: {
                                        HStack(alignment: .center, spacing: 10)
                                        {
                                            Button
                                            {
                                                outdatedPackageTracker.outdatedPackages = Set(outdatedPackageTracker.outdatedPackages.map({ modifiedElement in
                                                    var copyOutdatedPackage = modifiedElement
                                                    if copyOutdatedPackage.id == modifiedElement.id
                                                    {
                                                        copyOutdatedPackage.isMarkedForUpdating = false
                                                    }
                                                    return copyOutdatedPackage
                                                }))
                                            } label: {
                                                Text("start-page.updated.action.deselect-all")
                                            }
                                            .buttonStyle(.plain)
                                            .disabled(packagesMarkedForUpdating.count == 0)

                                            Button
                                            {
                                                outdatedPackageTracker.outdatedPackages = Set(outdatedPackageTracker.outdatedPackages.map({ modifiedElement in
                                                    var copyOutdatedPackage = modifiedElement
                                                    if copyOutdatedPackage.id == modifiedElement.id
                                                    {
                                                        copyOutdatedPackage.isMarkedForUpdating = true
                                                    }
                                                    return copyOutdatedPackage
                                                }))
                                            } label: {
                                                Text("start-page.updated.action.select-all")
                                            }
                                            .buttonStyle(.plain)
                                            .disabled(packagesMarkedForUpdating.count == outdatedPackageTracker.outdatedPackages.count)
                                        }
                                    }
                                }
                                .listStyle(.bordered(alternatesRowBackgrounds: true))
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
        .onChange(of: displayOnlyIntentionallyInstalledPackagesByDefault) 
        { _ in
            outdatedPackageTracker.updateDisplayableOutdatedPackages()
        }
    }
}
