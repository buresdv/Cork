//
//  Start Page.swift
//  Cork
//
//  Created by David Bureš on 10.02.2023.
//

import SwiftUI

struct StartPage: View
{
    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var availableTaps: AvailableTaps

    @EnvironmentObject var appState: AppState

    @EnvironmentObject var updateProgressTracker: UpdateProgressTracker
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker

    @State private var isLoadingUpgradeablePackages = true

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

                        if outdatedPackageTracker.outdatedPackages.count != 0
                        {
                            OutdatedPackageListBox()
                        }

                        PackageAndTapOverviewBox()

                        AnalyticsStatusBox()

                        if appState.cachedDownloadsFolderSize != 0
                        {
                            CachedDownloadsFolderInfoBox()
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
            if outdatedPackageTracker.outdatedPackages.isEmpty
            {
                Task(priority: .background)
                {
                    isLoadingUpgradeablePackages = true

                    await shell(AppConstants.brewExecutablePath.absoluteString, ["update"])

                    do
                    {
                        outdatedPackageTracker.outdatedPackages = try await getListOfUpgradeablePackages(brewData: brewData)
                    }
                    catch let outdatedPackageRetrievalError as OutdatedPackageRetrievalError
                    {
                        switch outdatedPackageRetrievalError
                        {
                        case .homeNotSet:
                            appState.fatalAlertType = .homePathNotSet
                            appState.isShowingFatalError = true
                        case .otherError:
                            print("Something went wrong")
                        }
                    }

                    if outdatedPackageTracker.outdatedPackages.isEmpty // Only play the slide out animation if there are no updates. Otherwise don't play it. This is because if there are updates, the "Updates available" GroupBox shows up and then immediately slides up, which is ugly.
                    {
                        withAnimation
                        {
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
