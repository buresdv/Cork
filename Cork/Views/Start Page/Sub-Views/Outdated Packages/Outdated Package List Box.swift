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
                                    .disabled(packagesMarkedForUpdating.count == 0)
                                }
                            }

                            DisclosureGroup(isExpanded: $isDropdownExpanded)
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
                                                        var copyOutdatedPackage = modifiedElement
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
                                            Button
                                            {
                                                outdatedPackageTracker.outdatedPackages = Set(outdatedPackageTracker.outdatedPackages.map
                                                { modifiedElement in
                                                    var copyOutdatedPackage = modifiedElement
                                                    if copyOutdatedPackage.id == modifiedElement.id
                                                    {
                                                        copyOutdatedPackage.isMarkedForUpdating = false
                                                    }
                                                    return copyOutdatedPackage
                                                })
                                            } label: {
                                                Text("start-page.updated.action.deselect-all")
                                            }
                                            .buttonStyle(.plain)
                                            .disabled(packagesMarkedForUpdating.count == 0)

                                            Button
                                            {
                                                outdatedPackageTracker.outdatedPackages = Set(outdatedPackageTracker.outdatedPackages.map
                                                { modifiedElement in
                                                    var copyOutdatedPackage = modifiedElement
                                                    if copyOutdatedPackage.id == modifiedElement.id
                                                    {
                                                        copyOutdatedPackage.isMarkedForUpdating = true
                                                    }
                                                    return copyOutdatedPackage
                                                })
                                            } label: {
                                                Text("start-page.updated.action.select-all")
                                            }
                                            .buttonStyle(.plain)
                                            .disabled(packagesMarkedForUpdating.count == outdatedPackageTracker.displayableOutdatedPackages.count)
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
    }
}

private struct OutdatedPackageListBoxRow: View
{
    let outdatedPackage: OutdatedPackage

    @State private var isExpanded: Bool = false

    var body: some View
    {
        VStack(alignment: .leading)
        {
            HStack(alignment: .center)
            {
                SanitizedPackageName(packageName: outdatedPackage.package.name, shouldShowVersion: true)

                Spacer()

                SUIButton(label: "")
                {
                    isExpanded.toggle()
                }
                .buttonStyle(.pushDisclosure)
            }
            if isExpanded
            {
                outdatedPackageDetails
            }
        }
    }

    @ViewBuilder
    var outdatedPackageDetails: some View
    {
        FullSizeGroupedForm
        {
            LabeledContent
            {
                Text("\(outdatedPackage.installedVersions.formatted(.list(type: .and))) → \(outdatedPackage.newerVersion)")
            } label: {
                Text("package-details.dependencies.results.version")
            }

            LabeledContent
            {
                Text(outdatedPackage.package.type.description)
            } label: {
                Text("package-details.type")
            }
        }
        .padding(-20)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
