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

    @State private var isOutdatedPackageDropdownExpanded: Bool = false
    
    @State private var dragOver: Bool = false

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
                    FullSizeGroupedForm
                    {
                        Section
                        {
                            OutdatedPackagesBox(isOutdatedPackageDropdownExpanded: $isOutdatedPackageDropdownExpanded)
                                .transition(.move(edge: .top))
                                .animation(.easeIn, value: appState.isCheckingForPackageUpdates)
                        } header: {
                            Text("start-page.status")
                                .font(.title)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        }

                        Section
                        {
                            PackageAndTapOverviewBox()
                        }

                        Section
                        {
                            AnalyticsStatusBox()
                        }

                        if appState.cachedDownloadsFolderSize != 0
                        {
                            Section
                            {
                                CachedDownloadsFolderInfoBox()
                            }
                        }
                    }
                    .scrollDisabled(!isOutdatedPackageDropdownExpanded)

                    ButtonBottomRow 
                    {
                        HStack
                        {
                            Spacer()

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
        }
        .task(priority: .background)
        {
            if outdatedPackageTracker.outdatedPackages.isEmpty
            {
                appState.isCheckingForPackageUpdates = true

                await shell(AppConstants.brewExecutablePath, ["update"])

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
                catch
                {
                    print("Unspecified error while pulling package updates")
                }

                withAnimation
                {
                    appState.isCheckingForPackageUpdates = false
                }
            }
        }
        .onDrop(of: [.homebrewBackup], isTargeted: $dragOver) { providers -> Bool in
            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                if let data = data, let path = String(data: data, encoding: .utf8), let url = URL(string: path as String) {
                    
                    if url.pathExtension == "brewbak" {
                        print("Correct File Format")
                        
                    } else {
                        print("Incorrect file format")
                    }
                }
            })
            return true
        }
    }
}
