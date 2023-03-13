//
//  Start Page.swift
//  Cork
//
//  Created by David Bureš on 10.02.2023.
//

import SwiftUI

struct StartPage: View
{
    @AppStorage("allowBrewAnalytics") var allowBrewAnalytics: Bool = true

    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var availableTaps: AvailableTaps

    @EnvironmentObject var appState: AppState

    @EnvironmentObject var updateProgressTracker: UpdateProgressTracker

    @State private var isLoadingUpgradeablePackages = true
    @State private var upgradeablePackages: [BrewPackage] = .init()

    @State private var isShowingFastCacheDeletionMaintenanceView: Bool = false

    @State private var isDisclosureGroupExpanded: Bool = false

    var body: some View
    {
        VStack
        {
            if isLoadingUpgradeablePackages
            {
                ProgressView
                {
                    Text("Checking for Package Updates...")
                }
            }
            else
            {
                VStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("Homebrew Status")
                            .font(.title)

                        if upgradeablePackages.count != 0
                        {
                            GroupBox
                            {
                                Grid
                                {
                                    GridRow(alignment: .firstTextBaseline)
                                    {
                                        VStack(alignment: .leading)
                                        {
                                            GroupBoxHeadlineGroupWithArbitraryContent(image: upgradeablePackages.count == 1 ? "square.and.arrow.down" : "square.and.arrow.down.on.square")
                                            {
                                                Text(upgradeablePackages.count == 1 ? "There is 1 outdated package" : "There are \(upgradeablePackages.count) outdated packages")
                                                    .font(.headline)
                                                DisclosureGroup(isExpanded: $isDisclosureGroupExpanded)
                                                {} label: {
                                                    Text("Outdated packages")
                                                        .font(.subheadline)
                                                }

                                                if isDisclosureGroupExpanded
                                                {
                                                    List(upgradeablePackages)
                                                    { package in
                                                        Text(package.name)
                                                    }
                                                    .listStyle(.bordered(alternatesRowBackgrounds: true))
                                                    .frame(height: 100)
                                                }
                                            }

                                            Button
                                            {
                                                Task
                                                {
                                                    await updatePackages(updateProgressTracker, appState: appState)
                                                }
                                            } label: {
                                                Text("Update")
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        if !appState.isLoadingFormulae && !appState.isLoadingCasks
                        {
                            GroupBox
                            {
                                VStack(alignment: .leading)
                                {
                                    GroupBoxHeadlineGroup(
                                        image: "terminal",
                                        title: "You have \(brewData.installedFormulae.count) Formulae installed",
                                        mainText: "Formulae are packages that you use through a terminal"
                                    )
                                    .animation(.none, value: brewData.installedFormulae.count)

                                    Divider()

                                    GroupBoxHeadlineGroup(
                                        image: "macwindow",
                                        title: "You have \(brewData.installedCasks.count) Casks installed",
                                        mainText: "Casks are packages that have graphical windows"
                                    )
                                    .animation(.none, value: brewData.installedCasks.count)

                                    Divider()

                                    GroupBoxHeadlineGroup(
                                        image: "spigot",
                                        title: "You have \(availableTaps.addedTaps.count) Taps added",
                                        mainText: "Taps provide additional packages"
                                    )
                                    .animation(.none, value: availableTaps.addedTaps.count)
                                }
                            }

                            GroupBox
                            {
                                VStack(alignment: .leading)
                                {
                                    GroupBoxHeadlineGroup(
                                        image: "chart.bar",
                                        title: "Homebrew analytics are \(allowBrewAnalytics ? "enabled" : "disabled")",
                                        mainText: "\(allowBrewAnalytics ? "Homebrew is collecting various anonymized data, such as which packages you have installed" : "Homebrew is not collecting any data about how you use it")"
                                    )
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                }
                            }

                            if appState.cachedDownloadsFolderSize != 0
                            {
                                GroupBox
                                {
                                    VStack
                                    {
                                        HStack
                                        {
                                            GroupBoxHeadlineGroup(
                                                image: "square.and.arrow.down.on.square",
                                                title: "You have \(appState.cachedDownloadsFolderSize.convertDirectorySizeToPresentableFormat(size: appState.cachedDownloadsFolderSize)) of cached downloads",
                                                mainText: "These files are leftovers from completed package installations. They're safe to remove."
                                            )

                                            Spacer()

                                            Button
                                            {
                                                appState.isShowingFastCacheDeletionMaintenanceView = true
                                            } label: {
                                                Text("Delete Cached Downloads…")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Spacer()

                    HStack
                    {
                        Spacer()
                        
                        UninstallationProgressWheel()

                        Button
                        {
                            print("Would perform maintenance")
                            appState.isShowingMaintenanceSheet.toggle()
                        } label: {
                            Text("Brew Maintenance…")
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear
        {
            Task(priority: .high)
            {
                isLoadingUpgradeablePackages = true
                upgradeablePackages = await getListOfUpgradeablePackages()
                isLoadingUpgradeablePackages = false
            }
        }
    }
}
