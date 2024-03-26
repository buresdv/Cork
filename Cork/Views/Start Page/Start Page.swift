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
                            HStack(alignment: .center, spacing: 10)
                            {
                                Text("start-page.status")
                                    .font(.title)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                
                                /*
                                Button
                                {
                                    NSWorkspace.shared.open(URL(string: "https://blog.corkmac.app/p/upcoming-changes-to-the-install-process")!)
                                } label: {
                                    Text("start-page.upcoming-changes")
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 1)
                                        .foregroundColor(.white)
                                        .background(.blue)
                                        .clipShape(.capsule)
                                }
                                .buttonStyle(.plain)
                                 */
                            }
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
                                AppConstants.logger.info("Would perform maintenance")
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
            if outdatedPackageTracker.allOutdatedPackages.isEmpty
            {
                appState.isCheckingForPackageUpdates = true

                await shell(AppConstants.brewExecutablePath, ["update"])

                do
                {
                    outdatedPackageTracker.allOutdatedPackages = try await getListOfUpgradeablePackages(brewData: brewData)
                }
                catch let outdatedPackageRetrievalError as OutdatedPackageRetrievalError
                {
                    switch outdatedPackageRetrievalError
                    {
                    case .homeNotSet:
                        appState.fatalAlertType = .homePathNotSet
                        appState.isShowingFatalError = true
                    case .otherError:
                            AppConstants.logger.error("Something went wrong")
                    }
                }
                catch
                {
                    AppConstants.logger.error("Unspecified error while pulling package updates")
                }

                withAnimation
                {
                    appState.isCheckingForPackageUpdates = false
                }
            }
        }
        .dropDestination(for: StringFile.self, action: { items, location in
            guard let backup = items.first else
            {
                return false
            }
            
            print(backup)
            
            return true
        }) { targeted in
            
        }
    }
}
