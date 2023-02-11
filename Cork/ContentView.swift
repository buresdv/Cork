//
//  ContentView.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI

struct ContentView: View
{
    @StateObject var appState = AppState()
    
    @StateObject var brewData = BrewDataStorage()

    @StateObject var availableTaps = AvailableTaps()

    @StateObject var selectedPackageInfo = SelectedPackageInfo()
    @StateObject var updateProgressTracker = UpdateProgressTracker()

    @State private var multiSelection = Set<UUID>()

    @State private var isShowingInstallSheet: Bool = false
    @State private var isShowingTapSheet: Bool = false
    @State private var isShowingAlert: Bool = false
    
    @State var numberOfInstalledFormulae: Int = 0
    @State var numberOfInstalledCasks: Int = 0

    var body: some View
    {
        VStack
        {
            NavigationView
            {
                List(selection: $multiSelection)
                {
                    Section("Installed Formulae")
                    {
                        if !appState.isLoadingFormulae
                        {
                            ForEach(brewData.installedFormulae)
                            { package in
                                NavigationLink
                                {
                                    PackageDetailView(package: package, isCask: false, brewData: brewData, packageInfo: selectedPackageInfo)
                                } label: {
                                    PackageListItem(packageItem: package)
                                }
                                .contextMenu
                                {
                                    Button
                                    {
                                        Task
                                        {
                                            await uninstallSelectedPackages(packages: [package.name], isCask: false, brewData: brewData)
                                        }
                                    } label: {
                                        Text("Uninstall Formula")
                                    }
                                }
                            }
                        }
                        else
                        {
                            ProgressView()
                                .onDisappear {
                                    numberOfInstalledFormulae = brewData.installedFormulae.count
                                    print("Number of installed Formulae: \(numberOfInstalledFormulae)")
                                }
                        }
                    }
                    .collapsible(true)

                    Section("Installed Casks")
                    {
                        if !appState.isLoadingCasks
                        {
                            ForEach(brewData.installedCasks)
                            { package in
                                NavigationLink
                                {
                                    PackageDetailView(package: package, isCask: true, brewData: brewData, packageInfo: selectedPackageInfo)
                                } label: {
                                    PackageListItem(packageItem: package)
                                }
                                .contextMenu
                                {
                                    Button
                                    {
                                        Task
                                        {
                                            await uninstallSelectedPackages(packages: [package.name], isCask: true, brewData: brewData)
                                        }
                                    } label: {
                                        Text("Uninstall Cask")
                                    }
                                }
                            }
                        }
                        else
                        {
                            ProgressView()
                                .onDisappear {
                                    numberOfInstalledCasks = brewData.installedCasks.count
                                    print("Number of installed Casks: \(numberOfInstalledCasks)")
                                }
                        }
                    }
                    .collapsible(true)

                    Section("Tapped Taps")
                    {
                        if availableTaps.tappedTaps.count != 0
                        {
                            ForEach(availableTaps.tappedTaps)
                            { tap in
                                Text(tap.name)
                            }
                        }
                        else
                        {
                            ProgressView()
                        }
                    }
                    .collapsible(false)
                }
                .listStyle(SidebarListStyle())
                
                StartPage(numberOfInstalledFormulae: $numberOfInstalledFormulae, numberOfInstalledCasks: $numberOfInstalledCasks, updateProgressTracker: updateProgressTracker)
            }
            .navigationTitle("Cork")
            .navigationSubtitle("\(numberOfInstalledFormulae + numberOfInstalledCasks) packages installed")
            .toolbar
            {
                ToolbarItemGroup(placement: .primaryAction)
                {
                    Button
                    {
                        upgradeBrewPackages(updateProgressTracker)
                    } label: {
                        Label
                        {
                            Text("Upgrade Formulae")
                        } icon: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    .keyboardShortcut("r")

                    Spacer()

                    Button
                    {
                        isShowingTapSheet.toggle()
                    } label: {
                        Label
                        {
                            Text("Add Tap")
                        } icon: {
                            Image(systemName: "spigot.fill")
                        }
                    }

                    Button
                    {
                        isShowingInstallSheet.toggle()
                    } label: {
                        Label
                        {
                            Text("Add Formula")
                        } icon: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
        .environmentObject(brewData)
        .onAppear
        {
            Task
            {
                await loadUpTappedTaps(into: availableTaps)
                await loadUpInstalledPackages(into: brewData, appState: appState)
            }
        }
        .sheet(isPresented: $isShowingInstallSheet)
        {
            AddFormulaView(isShowingSheet: $isShowingInstallSheet, brewData: brewData)
        }
        .sheet(isPresented: $isShowingTapSheet)
        {
            AddTapView(isShowingSheet: $isShowingTapSheet, availableTaps: availableTaps)
        }
        .sheet(isPresented: $updateProgressTracker.showUpdateSheet)
        {
            VStack
            {
                ProgressView(value: updateProgressTracker.updateProgress)
                    .frame(width: 200)
                Text(updateProgressTracker.updateStage.rawValue)
            }
            .padding()
        }
        .environmentObject(appState)
    }
}
