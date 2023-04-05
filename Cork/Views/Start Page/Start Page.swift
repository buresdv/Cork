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
                            OutdatedPackageLoaderBox()
                        }
                        
                        
                        if outdatedPackageTracker.outdatedPackageNames.count != 0
                        {
                            OutdatedPackageListBox()
                        }

                        PackageAndTapOverviewBox()

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
            if outdatedPackageTracker.outdatedPackageNames.isEmpty
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
}
