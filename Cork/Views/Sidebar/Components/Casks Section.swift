//
//  Casks Section.swift
//  Cork
//
//  Created by David Bureš on 03.06.2023.
//

import SwiftUI

struct CasksSection: View
{
    @AppStorage("sortPackagesBy") var sortPackagesBy: PackageSortingOptions = .byInstallDate

    @Environment(AppState.self) var appState: AppState
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker

    let searchText: String
    
    private var areNoCasksInstalled: Bool
    {
        if !appState.isLoadingCasks && brewPackagesTracker.numberOfInstalledCasks == 0
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
                if appState.isLoadingCasks
                {
                    ProgressView()
                }
                else
                {
                    ForEach(displayedCasks.sorted(by: { firstPackage, secondPackage in
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
                    { cask in
                        SidebarPackageRow(package: cask)
                    }
                }
            }
        }
        .collapsible(areNoCasksInstalled ? false : true)
    }

    private var displayedCasks: Set<BrewPackage>
    {
        if searchText.isEmpty || searchText.contains("#")
        {
            return brewPackagesTracker.successfullyLoadedCasks
        }
        else
        {
            return brewPackagesTracker.successfullyLoadedCasks.filter { $0.name.contains(searchText) }
        }
    }
}
