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

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var brewData: BrewDataStorage

    let searchText: String

    var body: some View
    {
        Section("sidebar.section.installed-casks")
        {
            if appState.failedWhileLoadingCasks
            {
                if #available(macOS 14.0, *)
                {
                    ContentUnavailableView("error.package-loading.could-not-load-casks.title", image: "custom.macwindow.badge.xmark")
                }
                else
                {
                    NoContentAvailableViewWithArbitraryImage(title: "error.package-loading.could-not-load-casks.title", image: "custom.macwindow.badge.xmark")
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
        .collapsible(true)
    }

    private var displayedCasks: Set<BrewPackage>
    {
        if searchText.isEmpty || searchText.contains("#")
        {
            return brewData.successfullyLoadedCasks
        }
        else
        {
            return brewData.successfullyLoadedCasks.filter { $0.name.contains(searchText) }
        }
    }
}
