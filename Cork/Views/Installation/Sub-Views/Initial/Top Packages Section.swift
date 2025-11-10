//
//  Top Packages Section.swift
//  Cork
//
//  Created by David Bureš on 17.10.2023.
//

import SwiftUI
import CorkShared
import Defaults
import CorkModels

struct TopPackagesSection: View
{
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker

    let packageTracker: TopPackagesTracker

    let trackerType: BrewPackage.PackageType
    
    private var packages: [BrewPackage]
    {
        switch trackerType
        {
        case .formula:
            packageTracker.sortedTopFormulae.filter
            {
                !brewPackagesTracker.successfullyLoadedFormulae.map(\.name).contains($0.name)
            }
        case .cask:
            packageTracker.sortedTopCasks.filter
            {
                !brewPackagesTracker.successfullyLoadedCasks.map(\.name).contains($0.name)
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
                    SearchResultRow(searchedForPackage: topPackage, context: .topPackages)
                }
            }
        } header: {
            CollapsibleSectionHeader(headerText: trackerType == .cask ? "add-package.top-casks" : "add-package.top-formulae", isCollapsed: $isCollapsed)
        }
    }
}
