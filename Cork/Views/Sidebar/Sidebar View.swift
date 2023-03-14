//
//  Sidebar View.swift
//  Cork
//
//  Created by David Bureš on 14.02.2023.
//

import SwiftUI

struct SidebarView: View
{
    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var availableTaps: AvailableTaps

    @EnvironmentObject var selectedPackageInfo: SelectedPackageInfo
    @EnvironmentObject var selectedTapInfo: SelectedTapInfo

    @State private var isShowingSearchField: Bool = false
    @State private var searchText: String = ""
    @State private var availableTokens: [PackageSearchToken] = AppConstants.packageSearchTokens
    @State private var currentTokens: [PackageSearchToken] = .init()
    
    var suggestedTokens: [PackageSearchToken]
    {
        if searchText.starts(with: "#")
        {
            return availableTokens
        }
        else
        {
            return []
        }
    }

    var body: some View
    {
        List
        {
            Section("Installed Formulae")
            {
                if !appState.isLoadingFormulae
                {
                    ForEach(searchText.isEmpty ? brewData.installedFormulae : brewData.installedFormulae.filter { $0.name.contains(searchText) })
                    { formula in
                        NavigationLink
                        {
                            PackageDetailView(package: formula, packageInfo: selectedPackageInfo)
                        } label: {
                            PackageListItem(packageItem: formula)
                        }
                        .contextMenu
                        {
                            Button
                            {
                                Task
                                {
                                    try await uninstallSelectedPackage(package: formula, brewData: brewData, appState: appState)
                                }
                            } label: {
                                Text("Uninstall \(formula.name)")
                            }
                        }
                    }
                }
                else
                {
                    ProgressView()
                }
            }
            .collapsible(false)

            Section("Installed Casks")
            {
                if !appState.isLoadingCasks
                {
                    ForEach(searchText.isEmpty ? brewData.installedCasks : brewData.installedCasks.filter { $0.name.contains(searchText) })
                    { cask in
                        NavigationLink
                        {
                            PackageDetailView(package: cask, packageInfo: selectedPackageInfo)
                        } label: {
                            PackageListItem(packageItem: cask)
                        }
                        .contextMenu
                        {
                            Button
                            {
                                Task
                                {
                                    try await uninstallSelectedPackage(package: cask, brewData: brewData, appState: appState)
                                }
                            } label: {
                                Text("Uninstall \(cask.name)")
                            }
                        }
                    }
                }
                else
                {
                    ProgressView()
                }
            }
            .collapsible(false)

            if searchText.isEmpty
            {
                Section("Added Taps")
                {
                    if availableTaps.addedTaps.count != 0
                    {
                        ForEach(availableTaps.addedTaps)
                        { tap in
                            
                            NavigationLink {
                                TapDetailView(tap: tap, selectedTapInfo: selectedTapInfo)
                            } label: {
                                Text(tap.name)
                            }
                            .contextMenu
                            {
                                Button
                                {
                                    Task(priority: .userInitiated)
                                    {
                                        print("Would remove \(tap.name)")
                                        try await removeTap(name: tap.name, availableTaps: availableTaps, appState: appState)
                                    }
                                } label: {
                                    Text("Remove \(tap.name)")
                                }
                                .alert(isPresented: $appState.isShowingRemoveTapFailedAlert, content: {
                                    Alert(title: Text("Couldn't remove \(tap.name)"), message: Text("Try again in a few minutes, or restart Cork"), dismissButton: .default(Text("Close"), action: {
                                        appState.isShowingRemoveTapFailedAlert = false
                                    }))
                                })
                            }
                            
                        }
                    }
                    else
                    {
                        ProgressView()
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 200)
        //.searchable(text: $searchText, placement: .sidebar, prompt: Text("Installed Packages"))
        .searchable(text: $searchText, tokens: $currentTokens, suggestedTokens: .constant(suggestedTokens), placement: .sidebar, prompt: Text("Search Packages"), token: { token in
            Text(token.name)
        })
        .sheet(isPresented: $appState.isShowingMaintenanceSheet)
        {
            MaintenanceView(isShowingSheet: $appState.isShowingMaintenanceSheet)
        }
        .sheet(isPresented: $appState.isShowingFastCacheDeletionMaintenanceView)
        {
            MaintenanceView(isShowingSheet: $appState.isShowingFastCacheDeletionMaintenanceView, shouldPurgeCache: false, shouldUninstallOrphans: false, shouldPerformHealthCheck: false, forcedOptions: true)
        }
    }
}
