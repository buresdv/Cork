//
//  Top Packages Section.swift
//  Cork
//
//  Created by David Bureš on 17.10.2023.
//

import SwiftUI

struct TopPackagesSection: View
{
    @EnvironmentObject var brewData: BrewDataStorage

    let packageTracker: TopPackagesTracker

    let trackerType: PackageType
    
    private var packages: [TopPackage]
    {
        switch trackerType
        {
        case .formula:
            packageTracker.sortedTopFormulae.filter
            {
                !brewData.successfullyLoadedFormulae.map(\.name).contains($0.packageName)
            }
        case .cask:
            packageTracker.sortedTopCasks.filter
            {
                !brewData.successfullyLoadedCasks.map(\.name).contains($0.packageName)
            }
        }
    }

    @State private var isCollapsed: Bool = false

    var body: some View
    {
        Section
        {
            if !isCollapsed
            {
                ForEach(packages.prefix(15))
                { topPackage in
                    SearchResultRow(searchedForPackage: BrewPackage(name: topPackage.packageName, type: trackerType, installedOn: nil, versions: [], sizeInBytes: nil), context: .topPackages, downloadCount: topPackage.packageDownloads)
                }
            }
        } header: {
            CollapsibleSectionHeader(headerText: trackerType == .cask ? "add-package.top-casks" : "add-package.top-formulae", isCollapsed: $isCollapsed)
        }
    }
}
