//
//  ContentView.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI

struct ContentView: View
{
    @AppStorage("sortPackagesBy") var sortPackagesBy: PackageSortingOptions = .none
    @AppStorage("allowBrewAnalytics") var allowBrewAnalytics: Bool = true
    
    @EnvironmentObject var appState: AppState

    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var availableTaps: AvailableTaps

    @EnvironmentObject var selectedPackageInfo: SelectedPackageInfo
    
    @EnvironmentObject var updateProgressTracker: UpdateProgressTracker

    @State private var multiSelection = Set<UUID>()

    @State private var isShowingAlert: Bool = false

    var body: some View
    {
        VStack
        {
            NavigationView
            {
                SidebarView()

                StartPage()
                    .frame(minWidth: 600, minHeight: 500)
            }
            .navigationTitle("Cork")
            .navigationSubtitle("\(brewData.installedFormulae.count + brewData.installedCasks.count) packages installed")
            .toolbar
            {
                ToolbarItemGroup(placement: .primaryAction)
                {
                    Button
                    {
                        appState.isShowingUpdateSheet = true
                    } label: {
                        Label
                        {
                            Text("Upgrade Packages")
                        } icon: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    .help("Upgrade installed packages")

                    Spacer()

                    Button
                    {
                        appState.isShowingAddTapSheet.toggle()
                    } label: {
                        Label
                        {
                            Text("Add Tap")
                        } icon: {
                            Image(systemName: "spigot")
                        }
                    }
                    .help("Add a new tap")

                    Button
                    {
                        appState.isShowingInstallationSheet.toggle()
                    } label: {
                        Label
                        {
                            Text("Install package")
                        } icon: {
                            Image(systemName: "plus")
                        }
                    }
                    .help("Install a new package")
                }
            }
        }
        .onAppear
        {
            print("Brew executable path: \(AppConstants.brewExecutablePath.absoluteString)")
            Task
            {
                await loadUpTappedTaps(into: availableTaps)
                async let analyticsQueryCommand = await shell(AppConstants.brewExecutablePath.absoluteString, ["analytics"])

                brewData.installedFormulae = await loadUpFormulae(appState: appState, sortBy: sortPackagesBy)
                brewData.installedCasks = await loadUpCasks(appState: appState, sortBy: sortPackagesBy)
                
                if await analyticsQueryCommand.standardOutput.contains("Analytics are enabled")
                {
                    allowBrewAnalytics = true
                    print("Analytics are ENABLED")
                }
                else
                {
                    allowBrewAnalytics = false
                    print("Analytics are DISABLED")
                }
            }
        }
        .onChange(of: sortPackagesBy, perform: { newSortOption in
            switch newSortOption {
            case .none:
                print("Chose NONE")
                
            case .alphabetically:
                print("Chose ALPHABETICALLY")
                brewData.installedFormulae = sortPackagesAlphabetically(brewData.installedFormulae)
                brewData.installedCasks = sortPackagesAlphabetically(brewData.installedCasks)
                
            case .byInstallDate:
                print("Chose BY INSTALL DATE")
                brewData.installedFormulae = sortPackagesByInstallDate(brewData.installedFormulae)
                brewData.installedCasks = sortPackagesByInstallDate(brewData.installedCasks)
                
            case .bySize:
                print("Chose BY SIZE")
                brewData.installedFormulae = sortPackagesBySize(brewData.installedFormulae)
                brewData.installedCasks = sortPackagesBySize(brewData.installedCasks)
            }
        })
        .sheet(isPresented: $appState.isShowingInstallationSheet)
        {
            AddFormulaView(isShowingSheet: $appState.isShowingInstallationSheet)
        }
        .sheet(isPresented: $appState.isShowingAddTapSheet)
        {
            AddTapView(isShowingSheet: $appState.isShowingAddTapSheet)
        }
        .sheet(isPresented: $appState.isShowingUpdateSheet)
        {
            UpdatePackagesView(isShowingSheet: $appState.isShowingUpdateSheet)
        }
        .alert(isPresented: $appState.isShowingUninstallationNotPossibleDueToDependencyAlert, content: {
            Alert(title: Text("Could Not Uninstall"), message: Text("This package is a dependency of \(appState.offendingDependencyProhibitingUninstallation)"), dismissButton: .default(Text("Close"), action: {
                appState.isShowingUninstallationNotPossibleDueToDependencyAlert = false
            }))
        })
    }
}
