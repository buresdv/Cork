//
//  Formulae Section.swift
//  Cork
//
//  Created by David Bureš on 03.06.2023.
//

import SwiftUI
import IdentifiedCollections

struct FormulaeSection: View {
    
    @AppStorage("sortPackagesBy") var sortPackagesBy: PackageSortingOptions = .none

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
                ForEach(formulaeToDisplayInSidebar)
                { formula in
                    SidebarPackageRow(package: formula)
                }
            }
        }
        .collapsible(true)
    }

    private var displayedFormulae: IdentifiedArrayOf<BrewPackage>
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

    private var formulaeToDisplayInSidebar: [BrewPackage]
    {
        switch sortPackagesBy {
            case .none:
                return Array(displayedFormulae)
            case .alphabetically:
                return displayedFormulae.sorted(by: { $0.name < $1.name })
            case .byInstallDate:
                return displayedFormulae.sorted(by: { $0.installedOn! < $1.installedOn! })
            case .bySize:
                return displayedFormulae.sorted(by: { $0.sizeInBytes! < $1.sizeInBytes! })
        }
    }
}
