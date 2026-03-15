//
//  Casks Section.swift
//  Cork
//
//  Created by David Bureš on 03.06.2023.
//

import SwiftUI
import CorkShared
import Defaults
import CorkModels
import FactoryKit

struct CasksSection: View
{
    @Default(.sortPackagesBy) var sortPackagesBy: PackageSortingOptions

    @InjectedObservable(\.appState) var appState: AppState
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker

    let searchText: String
    
    private var areNoCasksInstalled: Bool
    {
        if !brewPackagesTracker.isBeingLoaded && brewPackagesTracker.numberOfInstalledCasks == 0
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
        Section(areNoCasksInstalled ? "sidebar.status.no-casks-installed" : "sidebar.section.installed-casks")
        {
            if appState.failedWhileLoadingCasks
            {
                HStack
                {
                    Image("custom.macwindow.badge.xmark")
                    Text("error.package-loading.could-not-load-casks.title")
                }
            }
            else
            {
                if brewPackagesTracker.isBeingLoaded
                {
                    ProgressView()
                }
                else
                {
                    ForEach(displayedCasks.sorted(by: { firstPackage, secondPackage in
                        switch sortPackagesBy
                        {
                        case .alphabetically:
                            return firstPackage.name(withPrecision: .precise) < secondPackage.name(withPrecision: .precise)
                        case .byInstallDate:
                            return firstPackage.installedOn! < secondPackage.installedOn!
                        case .bySize:
                            return firstPackage.sizeInBytes! > secondPackage.sizeInBytes!
                        }
                    }))
                    { cask in
                        SidebarPackageRow(package: cask)
                    }
                }
            }
        }
        .collapsible(areNoCasksInstalled ? false : true)
        .accessibilityLabel("accessibility.label.sidebar.casks-section")
    }

    private var displayedCasks: Set<BrewPackage>
    {
        if searchText.isEmpty || searchText.contains("#")
        {
            return brewPackagesTracker.successfullyLoadedCasks
        }
        else
        {
            return brewPackagesTracker.successfullyLoadedCasks.filter { $0.name(withPrecision: .precise).contains(searchText) }
        }
    }
}
