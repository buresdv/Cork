//
//  Sidebar View.swift
//  Cork
//
//  Created by David Bureš on 14.02.2023.
//

import SwiftUI

struct SidebarView: View
{
    @AppStorage("allowMoreCompleteUninstallations") var allowMoreCompleteUninstallations: Bool = false

    @EnvironmentObject var appState: AppState

    @State private var isShowingSearchField: Bool = false
    @State private var searchText: String = ""
    @State private var availableTokens: [PackageSearchToken] = [
        .formula, .cask, .tap, .intentionallyInstalledPackage,
    ]
    @State private var currentTokens: [PackageSearchToken] = .init()

    var suggestedTokens: [PackageSearchToken]
    {
        if searchText.contains("#")
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
        /// Navigation selection enables "Home" button behaviour. [2023.09]
        List(selection: $appState.navigationSelection)
        {
            if currentTokens.isEmpty || currentTokens.contains(.formula) || currentTokens.contains(.intentionallyInstalledPackage)
            {
                FormulaeSection(currentTokens: currentTokens, searchText: searchText)
            }

            if currentTokens.isEmpty || currentTokens.contains(.cask) || currentTokens.contains(.intentionallyInstalledPackage)
            {
                CasksSection(searchText: searchText)
            }

            if currentTokens.isEmpty || currentTokens.contains(.tap)
            {
                TapsSection(searchText: searchText)
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 200)
        .modify
        { viewProxy in
            if #available(macOS 14.0, *)
            {
                viewProxy
                    .searchable(text: $searchText, tokens: $currentTokens, suggestedTokens: .constant(suggestedTokens), isPresented: $appState.isSearchFieldFocused, placement: .sidebar, prompt: Text("sidebar.search.prompt"))
                    { token in
                        Label
                        {
                            Text(token.name)
                        } icon: {
                            Image(systemName: token.icon)
                                .foregroundColor(Color.blue)
                        }
                    }
            }
            else
            {
                viewProxy
                    .searchable(text: $searchText, tokens: $currentTokens, suggestedTokens: .constant(suggestedTokens), placement: .sidebar, prompt: Text("sidebar.search.prompt"))
                    { token in
                        Label
                        {
                            Text(token.name)
                        } icon: {
                            Image(systemName: token.icon)
                                .foregroundColor(Color.blue)
                        }
                    }
            }
        }
        .toolbar(id: "SidebarToolbar")
        {
            ToolbarItem(id: "homeButton", placement: .automatic)
            {
                Button
                {
                    appState.navigationSelection = nil
                } label: {
                    Label("action.go-to-status-page", systemImage: "house")
                }
                .help("action.go-to-status-page")
                .disabled(appState.navigationSelection == nil || !searchText.isEmpty || !currentTokens.isEmpty)
            }
            .defaultCustomization(.visible, options: .alwaysAvailable)
        }
        .sheet(isPresented: $appState.isShowingMaintenanceSheet)
        {
            MaintenanceView()
        }
        .sheet(isPresented: $appState.isShowingFastCacheDeletionMaintenanceView)
        {
            MaintenanceView(shouldPurgeCache: false, shouldUninstallOrphans: false, shouldPerformHealthCheck: false, forcedOptions: true)
        }
    }
}
