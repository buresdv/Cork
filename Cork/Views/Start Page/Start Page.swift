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

    @State var updateProgressTracker: UpdateProgressTracker

    @State private var isLoadingUpgradeablePackages = true
    @State private var upgradeablePackages: [BrewPackage] = .init()

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

                        GroupBox
                        {
                            if upgradeablePackages.count == 0
                            {
                                GroupBoxHeadlineGroup(title: "You are all up-to-date", mainText: "There are no packages to update")
                            }
                            else
                            {
                                Grid
                                {
                                    GridRow(alignment: .firstTextBaseline)
                                    {
                                        if upgradeablePackages.count == 1
                                        {
                                            VStack(alignment: .leading)
                                            {
                                                Text("There is 1 outdated package")
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
                                                    .frame(maxHeight: 100)
                                                }
                                            }
                                        }
                                        else
                                        {
                                            VStack(alignment: .leading)
                                            {
                                                Text("There are \(upgradeablePackages.count) outdated packages")
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
                                                    .frame(maxHeight: 100)
                                                }
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
                                        GroupBoxHeadlineGroup(title: "You have \(brewData.installedCasks.count) Casks instaled", mainText: "Casks are usually graphical apps")
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
        .sheet(isPresented: $appState.isShowingMaintenanceSheet)
        {
            MaintenanceView(isShowingSheet: $appState.isShowingMaintenanceSheet)
        }
    }
}
