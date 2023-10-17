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

    let packageTracker: [TopPackage]

    let isCaskTracker: Bool

    @State private var isCollapsed: Bool = false

    var body: some View
    {
        Section
        {
            if !isCollapsed
            {
                ForEach(packageTracker.filter
                {
                    if !isCaskTracker
                    {
                        !brewData.installedFormulae.map(\.name).contains($0.packageName)
                    }
                    else
                    {
                        !brewData.installedCasks.map(\.name).contains($0.packageName)
                    }

                }.prefix(15))
                { topFormula in
                    TopPackageListItem(topPackage: topFormula)
                }
            }
        } header: {
            CollapsibleSectionHeader(headerText: isCaskTracker ? "add-package.top-casks" : "add-package.top-formulae", isCollapsed: $isCollapsed)
        }
    }
}
