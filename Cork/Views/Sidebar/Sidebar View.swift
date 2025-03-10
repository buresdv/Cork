//
//  Sidebar View.swift
//  Cork
//
//  Created by David Bureš on 14.02.2023.
//

import SwiftUI
import CorkShared
import Defaults

struct SidebarView: View
{
    @Default(.allowMoreCompleteUninstallations) var allowMoreCompleteUninstallations

    @Environment(AppState.self) var appState: AppState

    @State private var isShowingSearchField: Bool = false
    @State private var searchText: String = ""
    @State private var availableTokens: [PackageSearchToken] = [
        .formula, .cask, .tap, .intentionallyInstalledPackage
    ]
    @State private var currentTokens: [PackageSearchToken] = .init()
    
    @State private var localNavigationTragetId: UUID?

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
        @Bindable var appState: AppState = appState
        /// Navigation selection enables "Home" button behaviour. [2023.09]
        List(selection: $localNavigationTragetId)
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
        .onChange(of: localNavigationTragetId)
        { _, newValue in
            if appState.navigationTargetId != newValue {
                appState.navigationTargetId = newValue
            }
        }
        .onReceive(appState.navigationTargetId.publisher.receive(on: DispatchQueue.main))
        { newValue in
            if localNavigationTragetId != newValue {
                localNavigationTragetId = newValue
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 200)
        .modify
        { viewProxy in
            if #available(macOS 14.0, *)
            {
                viewProxy
                    .searchable(text: $searchText, tokens: $currentTokens, suggestedTokens: .constant(suggestedTokens), isPresented: Bindable(appState).isSearchFieldFocused, placement: .sidebar, prompt: Text("sidebar.search.prompt"))
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
                    appState.navigationTargetId = nil
                } label: {
                    Label("action.go-to-status-page", systemImage: "house")
                }
                .help("action.go-to-status-page")
                .disabled(
                    appState.navigationTargetId == nil || !searchText.isEmpty || !currentTokens.isEmpty
                )
            }
            .defaultCustomization(.visible, options: .alwaysAvailable)
        }
    }
}
