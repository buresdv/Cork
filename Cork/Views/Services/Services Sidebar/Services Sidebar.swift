//
//  Services Sidebar.swift
//  Cork
//
//  Created by David Bureš on 20.03.2024.
//

import SwiftUI

struct ServicesSidebarView: View
{
    @EnvironmentObject var servicesState: ServicesState
    @EnvironmentObject var servicesTracker: ServicesTracker

    @State private var searchText: String = ""
    
    @State private var localNavigationTargetId: UUID?

    var body: some View
    {
        List(selection: $localNavigationTargetId)
        {
            ForEach(displayedServices.sorted(by: { $0.name < $1.name }))
            { homebrewService in
                SidebarServiceRow(service: homebrewService)
            }
        }
        .toolbar(id: "ServicesSidebarToolbar")
        {
            ToolbarItem(id: "servicesHomeButton", placement: .automatic)
            {
                Button
                {
                    servicesState.navigationTargetId = nil
                } label: {
                    Label("action.go-to-status-page", systemImage: "house")
                }
                .help("action.go-to-status-page")
                .disabled(servicesState.navigationTargetId == nil)
            }
            .defaultCustomization(.visible, options: .alwaysAvailable)
        }
        .searchable(text: $searchText, placement: .sidebar, prompt: Text("services-sidebar.search.prompt"))
        .onChange(of: localNavigationTargetId)
        { newValue in
            if servicesState.navigationTargetId != newValue {
                servicesState.navigationTargetId = newValue
            }
        }
    }

    private var displayedServices: Set<HomebrewService>
    {
        let filter: (HomebrewService) -> Bool

        if searchText.isEmpty
        {
            filter = { _ in true }
        }
        else
        {
            filter = { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        return servicesTracker.services.filter(filter)
    }
}
