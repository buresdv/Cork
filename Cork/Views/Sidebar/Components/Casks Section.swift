//
//  Casks Section.swift
//  Cork
//
//  Created by David Bureš on 03.06.2023.
//

import SwiftUI
import IdentifiedCollections

struct CasksSection: View {
    
    @AppStorage("sortPackagesBy") var sortPackagesBy: PackageSortingOptions = .none

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
                ForEach(casksToDisplayInSidebar)
                { cask in
                    SidebarPackageRow(package: cask)
                }
            }
        }
        .collapsible(true)
    }

    private var displayedCasks: IdentifiedArrayOf<BrewPackage>
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

    private var casksToDisplayInSidebar: [BrewPackage]
    {
        switch sortPackagesBy {
            case .none:
                return Array(displayedCasks)
            case .alphabetically:
                return displayedCasks.sorted(by: { $0.name < $1.name })
            case .byInstallDate:
                return displayedCasks.sorted(by: { $0.installedOn! < $1.installedOn! })
            case .bySize:
                return displayedCasks.sorted(by: { $0.sizeInBytes! < $1.sizeInBytes! })
        }
    }
}
