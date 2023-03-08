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
                                            updateBrewPackages(updateProgressTracker, appState: appState)
                                        } label: {
                                            Text("Update")
                                        }
                                    }
                                }
                            }
                        }

                        if !appState.isLoadingFormulae && !appState.isLoadingCasks
                        {
                            GroupBox
                            {
                                Grid(alignment: .leading)
                                {
                                    GridRow(alignment: .firstTextBaseline)
                                    {
                                        GroupBoxHeadlineGroup(title: "You have \(brewData.installedFormulae.count) Formulae installed", mainText: "Formulae are usually apps that you run in a terminal")
                                            .animation(.none, value: brewData.installedFormulae.count)
                                    }

                                    Divider()

                                    GridRow(alignment: .firstTextBaseline)
                                    {
                                        GroupBoxHeadlineGroup(title: "You have \(brewData.installedCasks.count) Casks installed", mainText: "Casks are usually graphical apps")
                                            .animation(.none, value: brewData.installedCasks.count)
                                    }

                                    Divider()

                                    GridRow(alignment: .firstTextBaseline)
                                    {
                                        GroupBoxHeadlineGroup(title: "You have \(availableTaps.tappedTaps.count) Taps tapped", mainText: "Taps are sources of packages that are not provided by Homebrew itself")
                                            .animation(.none, value: availableTaps.tappedTaps.count)
                                    }
                                }
                            }
                            
                            GroupBox
                            {
                                Grid(alignment: .leading)
                                {
                                    GridRow(alignment: .firstTextBaseline)
                                    {
                                        GroupBoxHeadlineGroup(title: "Brew analytics are \(allowBrewAnalytics ? "enabled" : "disabled")", mainText: "\(allowBrewAnalytics ? "Brew is collecting various anonymized data, such as which packages you have installed" : "Brew is not collecting any data about how you use it")")
                                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                            
                            if appState.cachedDownloadsFolderSize != 0
                            {
                                GroupBox
                                {
                                    Grid(alignment: .leading) {
                                        GridRow(alignment: .center) {
                                            HStack
                                            {
                                                GroupBoxHeadlineGroup(title: "You have \(appState.cachedDownloadsFolderSize.convertDirectorySizeToPresentableFormat(size: appState.cachedDownloadsFolderSize)) of cached downloads", mainText: "These files were used for installing packages.\nThey are safe to remove.")
                                                
                                                Spacer()
                                                
                                                Button {
                                                    appState.isShowingFastCacheDeletionMaintenanceView = true
                                                } label: {
                                                    Text("Delete Cached Downloads")
                                                }
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
                            Text("Brew Maintenance")
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
