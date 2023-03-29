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
    @State private var availableTokens: [PackageSearchToken] = [
        PackageSearchToken(name: "search.token.filter-formulae", icon: "terminal", tokenSearchResultType: .formula),
        PackageSearchToken(name: "search.token.filter-casks", icon: "macwindow", tokenSearchResultType: .cask),
        PackageSearchToken(name: "search.token.filter-taps", icon: "spigot", tokenSearchResultType: .tap),
        PackageSearchToken(name: "search.token.filter-manually-installed-packages", icon: "hand.tap", tokenSearchResultType: .intentionallyInstalledPackage)
    ]
    @State private var currentTokens: [PackageSearchToken] = .init()

    var suggestedTokens: [PackageSearchToken]
    {
        if searchText.starts(with: "#")
        {
            return availableTokens
        }
        else
        {
            return .init()
        }
    }

    var body: some View
    {
        List
        {
            if currentTokens.isEmpty || currentTokens.contains(where: { $0.tokenSearchResultType == .formula }) || currentTokens.contains(where: { $0.tokenSearchResultType == .intentionallyInstalledPackage })
            {
                Section("sidebar.section.installed-formulae")
                {
                    if !appState.isLoadingFormulae
                    {
                        
                        if currentTokens.contains(where: { $0.tokenSearchResultType == .intentionallyInstalledPackage })
                        {
                            ForEach(searchText.isEmpty ? brewData.installedFormulae.filter({ $0.installedIntentionally == true }) : brewData.installedFormulae.filter({ $0.installedIntentionally == true && $0.name.contains(searchText)}))
                            { formula in
                                NavigationLink
                                {
                                    PackageDetailView(package: formula, packageInfo: selectedPackageInfo)
                                } label: {
                                    PackageListItem(packageItem: formula)
                                }
                                .contextMenu
                                {
                                    if !formula.isTagged
                                    {
                                        Button
                                        {
                                            Task
                                            {
                                                await tagPackage(package: formula, brewData: brewData, appState: appState)
                                            }
                                        } label: {
                                            Text("sidebar.section.all.contextmenu.tag-\(formula.name)")
                                        }
                                    }
                                    else
                                    {
                                        Button
                                        {
                                            Task
                                            {
                                                await untagPackage(package: formula, brewData: brewData, appState: appState)
                                            }
                                        } label: {
                                            Text("sidebar.section.all.contextmenu.untag-\(formula.name)")
                                        }
                                    }

                                    Divider()

                                    Button
                                    {
                                        Task
                                        {
                                            try await uninstallSelectedPackage(package: formula, brewData: brewData, appState: appState)
                                        }
                                    } label: {
                                        Text("sidebar.section.installed-formulae.contextmenu.uninstall-\(formula.name)")
                                    }
                                }
                            }
                        }
                        else
                        {
                            ForEach(searchText.isEmpty || searchText.contains("#") ? brewData.installedFormulae : brewData.installedFormulae.filter { $0.name.contains(searchText) })
                            { formula in
                                NavigationLink
                                {
                                    PackageDetailView(package: formula, packageInfo: selectedPackageInfo)
                                } label: {
                                    PackageListItem(packageItem: formula)
                                }
                                .contextMenu
                                {
                                    if !formula.isTagged
                                    {
                                        Button
                                        {
                                            Task
                                            {
                                                await tagPackage(package: formula, brewData: brewData, appState: appState)
                                            }
                                        } label: {
                                            Text("sidebar.section.all.contextmenu.tag-\(formula.name)")
                                        }
                                    }
                                    else
                                    {
                                        Button
                                        {
                                            Task
                                            {
                                                await untagPackage(package: formula, brewData: brewData, appState: appState)
                                            }
                                        } label: {
                                            Text("sidebar.section.all.contextmenu.untag-\(formula.name)")
                                        }
                                    }

                                    Divider()

                                    Button
                                    {
                                        Task
                                        {
                                            try await uninstallSelectedPackage(package: formula, brewData: brewData, appState: appState)
                                        }
                                    } label: {
                                        Text("sidebar.section.installed-formulae.contextmenu.uninstall-\(formula.name)")
                                    }
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
            }

            if currentTokens.isEmpty || currentTokens.contains(where: { $0.tokenSearchResultType == .cask }) || currentTokens.contains(where: { $0.tokenSearchResultType == .intentionallyInstalledPackage })
            {
                Section("sidebar.section.installed-casks")
                {
                    if !appState.isLoadingCasks
                    {
                        ForEach(searchText.isEmpty || searchText.contains("#") ? brewData.installedCasks : brewData.installedCasks.filter { $0.name.contains(searchText) })
                        { cask in
                            NavigationLink
                            {
                                PackageDetailView(package: cask, packageInfo: selectedPackageInfo)
                            } label: {
                                PackageListItem(packageItem: cask)
                            }
                            .contextMenu
                            {
                                if cask.isTagged
                                {
                                    Button
                                    {
                                        Task
                                        {
                                            await untagPackage(package: cask, brewData: brewData, appState: appState)
                                        }
                                    } label: {
                                        Text("sidebar.section.all.contextmenu.untag-\(cask.name)")
                                    }
                                }
                                else
                                {
                                    Button
                                    {
                                        Task
                                        {
                                            await tagPackage(package: cask, brewData: brewData, appState: appState)
                                        }
                                    } label: {
                                        Text("sidebar.section.all.contextmenu.tag-\(cask.name)")
                                    }
                                }

                                Divider()

                                Button
                                {
                                    Task
                                    {
                                        try await uninstallSelectedPackage(package: cask, brewData: brewData, appState: appState)
                                    }
                                } label: {
                                    Text("sidebar.section.installed-casks.contextmenu.uninstall-\(cask.name)")
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
            }

            if currentTokens.isEmpty || currentTokens.contains(where: { $0.tokenSearchResultType == .tap })
            {
                Section("sidebar.section.added-taps")
                {
                    if availableTaps.addedTaps.count != 0
                    {
                        ForEach(searchText.isEmpty || searchText.contains("#") ? availableTaps.addedTaps : availableTaps.addedTaps.filter { $0.name.contains(searchText) })
                        { tap in

                            NavigationLink
                            {
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
                                    Text("sidebar.section.added-taps.contextmenu.remove-\(tap.name)")
                                }
                                .alert(isPresented: $appState.isShowingRemoveTapFailedAlert, content: {
                                    Alert(title: Text("sidebar.section.added-taps.remove.title-\(tap.name)"), message: Text("sidebar.section.added-taps.remove.message"), dismissButton: .default(Text("action.close"), action: {
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
        .searchable(text: $searchText, tokens: $currentTokens, suggestedTokens: .constant(suggestedTokens), placement: .sidebar, prompt: Text("sidebar.search.prompt"))
        { token in
            Label {
                Text(token.name)
            } icon: {
                Image(systemName: token.icon)
                    .foregroundColor(Color.blue)
            }

        }
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
