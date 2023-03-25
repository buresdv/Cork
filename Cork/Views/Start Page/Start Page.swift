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
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker

    @State private var isLoadingUpgradeablePackages = true

    @State private var isShowingFastCacheDeletionMaintenanceView: Bool = false

    @State private var isDisclosureGroupExpanded: Bool = false

    var body: some View
    {
        VStack
        {
            if appState.isLoadingFormulae && appState.isLoadingCasks || availableTaps.addedTaps.isEmpty
            {
                ProgressView("start-page.loading")
            }
            else
            {
                VStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("start-page.status")
                            .font(.title)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                        if isLoadingUpgradeablePackages
                        {
                            GroupBox
                            {
                                Grid
                                {
                                    GridRow(alignment: .firstTextBaseline) {
                                        HStack(alignment: .center, spacing: 15)
                                        {
                                            ProgressView()

                                            Text("start-page.updates.loading")
                                        }
                                        .padding(10)
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        
                        
                        if outdatedPackageTracker.outdatedPackageNames.count != 0
                        {
                            GroupBox
                            {
                                Grid
                                {
                                    GridRow(alignment: .firstTextBaseline)
                                    {
                                        VStack(alignment: .leading)
                                        {
                                            GroupBoxHeadlineGroupWithArbitraryContent(image: outdatedPackageTracker.outdatedPackageNames.count == 1 ? "square.and.arrow.down" : "square.and.arrow.down.on.square")
                                            {
                                                HStack(alignment: .firstTextBaseline)
                                                {
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text("start-page.updates.count-\(outdatedPackageTracker.outdatedPackageNames.count)")
                                                            .font(.headline)
                                                        DisclosureGroup(isExpanded: $isDisclosureGroupExpanded)
                                                        {} label: {
                                                            Text("start-page.updates.list")
                                                                .font(.subheadline)
                                                        }

                                                        if isDisclosureGroupExpanded
                                                        {
                                                            List
                                                            {
                                                                ForEach(outdatedPackageTracker.outdatedPackageNames, id: \.self) { outdatedPackageName in
                                                                    Text(outdatedPackageName)
                                                                }
                                                            }
                                                            .listStyle(.bordered(alternatesRowBackgrounds: true))
                                                            .frame(height: 100)
                                                        }
                                                    }
                                                    
                                                    Spacer()
                                                    
                                                    Button
                                                    {
                                                        appState.isShowingUpdateSheet = true
                                                    } label: {
                                                        Text("start-page.updates.action")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        GroupBox
                        {
                            VStack(alignment: .leading)
                            {
                                GroupBoxHeadlineGroup(
                                    image: "terminal",
                                    title: "start-page.installed-formulae.count-\(brewData.installedFormulae.count)",
                                    mainText: "start-page.installed-formulae.description"
                                )
                                .animation(.none, value: brewData.installedFormulae.count)

                                Divider()

                                GroupBoxHeadlineGroup(
                                    image: "macwindow",
                                    title: "start-page.installed-casks.count-\(brewData.installedCasks.count)",
                                    mainText: "start-page.installed-casks.description"
                                )
                                .animation(.none, value: brewData.installedCasks.count)

                                Divider()

                                GroupBoxHeadlineGroup(
                                    image: "spigot",
                                    title: "start-page.added-taps.count-\(availableTaps.addedTaps.count)",
                                    mainText: "start-page.added-taps.description"
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
                                    title: allowBrewAnalytics ? "start-page.analytics.enabled" : "start-page.analytics.disabled",
                                    mainText: allowBrewAnalytics ? "start-page.analytics.enabled.description" : "start-page.analytics.disabled.description"
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
                                            title: "start-page.cached-downloads-\(appState.cachedDownloadsFolderSize.formatted(.byteCount(style: .file)))",
                                            mainText: "start-page.cached-downloads.description"
                                        )

                                        Spacer()

                                        Button
                                        {
                                            appState.isShowingFastCacheDeletionMaintenanceView = true
                                        } label: {
                                            Text("start-page.cached-downloads.action")
                                        }
                                        .padding(.trailing, 7)
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
                            Text("start-page.open-maintenance")
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear
        {
            Task(priority: .background)
            {
                isLoadingUpgradeablePackages = true
                
                await shell(AppConstants.brewExecutablePath.absoluteString, ["update"])
                            
                outdatedPackageTracker.outdatedPackageNames = await getListOfUpgradeablePackages()
                
                if outdatedPackageTracker.outdatedPackageNames.isEmpty // Only play the slide out animation if there are no updates. Otherwise don't play it. This is because if there are updates, the "Updates available" GroupBox shows up and then immediately slides up, which is ugly.
                {
                    withAnimation {
                        isLoadingUpgradeablePackages = false
                    }
                }
                else
                {
                    isLoadingUpgradeablePackages = false
                }
                
            }
        }
    }
}
