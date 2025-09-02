//
//  Formulae Section.swift
//  Cork
//
//  Created by David Bureš on 03.06.2023.
//

import SwiftUI
import CorkShared
import Defaults

struct FormulaeSection: View
{
    @Default(.displayOnlyIntentionallyInstalledPackagesByDefault) var displayOnlyIntentionallyInstalledPackagesByDefault: Bool
    @Default(.sortPackagesBy) var sortPackagesBy: PackageSortingOptions

    @Environment(AppState.self) var appState: AppState
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker

    let currentTokens: [PackageSearchToken]
    let searchText: String
    
    private var areNoFormulaeInstalled: Bool
    {
        if !appState.isLoadingFormulae && brewPackagesTracker.numberOfInstalledFormulae == 0
        {
            return true
        }
        else
        {
            return false
        }
    }

    var body: some View
    {
        Section(areNoFormulaeInstalled ? "sidebar.status.no-formulae-installed" : "sidebar.section.installed-formulae")
        {
            if appState.failedWhileLoadingFormulae
            {
                HStack
                {
                    Image("custom.terminal.badge.xmark")
                    Text("error.package-loading.could-not-load-formulae.title")
                }
            }
            else
            {
                if appState.isLoadingFormulae
                {
                    ProgressView()
                }
                else
                {
                    ForEach(displayedFormulae.sorted(by: { firstPackage, secondPackage in
                        switch sortPackagesBy
                        {
                        case .alphabetically:
                            return firstPackage.name < secondPackage.name
                        case .byInstallDate:
                            return firstPackage.installedOn! < secondPackage.installedOn!
                        case .bySize:
                            return firstPackage.sizeInBytes! > secondPackage.sizeInBytes!
                        }
                    }))
                    { formula in
                        SidebarPackageRow(package: formula)
                    }
                }
            }
        }
        .collapsible(areNoFormulaeInstalled ? false : true)
        .accessibilityLabel("accessibility.label.sidebar.formulae-section")
    }

    private var displayedFormulae: Set<BrewPackage>
    {
        let filter: (BrewPackage) -> Bool

        if currentTokens.contains(.intentionallyInstalledPackage) || displayOnlyIntentionallyInstalledPackagesByDefault
        {
            if searchText.isEmpty
            {
                filter = \.installedIntentionally
            }
            else
            {
                filter = { $0.installedIntentionally && $0.name.contains(searchText) }
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

        return brewPackagesTracker.successfullyLoadedFormulae.filter(filter)
    }
}
