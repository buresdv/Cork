//
//  Formulae Section.swift
//  Cork
//
//  Created by David Bureš on 03.06.2023.
//

import SwiftUI

struct FormulaeSection: View {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var brewData: BrewDataStorage
    
    let currentTokens: [PackageSearchToken]
    let searchText: String

    var body: some View {
        Section("sidebar.section.installed-formulae")
        {
            if appState.isLoadingFormulae
            {
                ProgressView()
            }
            else
            {
                ForEach(displayedFormulae)
                { formula in
                    SidebarPackageRow(package: formula)
                }
            }
        }
        .collapsible(true)
    }

    private var displayedFormulae: [BrewPackage]
    {
        let filter: (BrewPackage) -> Bool

        if currentTokens.contains(.intentionallyInstalledPackage)
        {
            if searchText.isEmpty
            {
                filter = \.installedIntentionally
            } else
            {
                filter = { $0.installedIntentionally && $0.name.contains(searchText)  }
            }
        } 
        else
        {
            if searchText.isEmpty || searchText.contains("#")
            {
                filter = { _ in true }
            } 
            else
            {
                filter = { $0.name.contains(searchText) }
            }
        }

        return brewData.installedFormulae.filter(filter)
    }
}
