//
//  Casks Section.swift
//  Cork
//
//  Created by David Bureš on 03.06.2023.
//

import SwiftUI

struct CasksSection: View {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var brewData: BrewDataStorage
    
    let searchText: String
    
    var body: some View {
        Section("sidebar.section.installed-casks")
        {
            if appState.isLoadingCasks
            {
                ProgressView()
            }
            else
            {
                ForEach(displayedCasks)
                { cask in
                    SidebarPackageRow(package: cask)
                }
            }
        }
        .collapsible(true)
    }

    private var displayedCasks: [BrewPackage]
    {
        if searchText.isEmpty || searchText.contains("#")
        {
            return brewData.installedCasks
        } 
        else
        {
            return brewData.installedCasks.filter { $0.name.contains(searchText) }
        }
    }
}
