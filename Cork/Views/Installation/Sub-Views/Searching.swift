//
//  Searching View.swift
//  Cork
//
//  Created by David Bureš on 20.08.2023.
//

import SwiftUI

struct InstallationSearchingView: View, Sendable
{
    @Binding var packageRequested: String

    @Bindable var searchResultTracker: SearchResultTracker

    @Binding var packageInstallationProcessStep: PackageInstallationProcessSteps

    var body: some View
    {
        ProgressView("add-package.searching-\(packageRequested)")
            .task
            {
                searchResultTracker.foundFormulae = []
                searchResultTracker.foundCasks = []

                async let foundFormulae: [String] = searchForPackage(packageName: packageRequested, packageType: .formula)
                async let foundCasks: [String] = searchForPackage(packageName: packageRequested, packageType: .cask)

                for formula in await foundFormulae
                {
                    searchResultTracker.foundFormulae.append(BrewPackage(name: formula, type: .formula, installedOn: nil, versions: [], sizeInBytes: nil, downloadCount: nil))
                }
                for cask in await foundCasks
                {
                    searchResultTracker.foundCasks.append(BrewPackage(name: cask, type: .cask, installedOn: nil, versions: [], sizeInBytes: nil, downloadCount: nil))
                }

                packageInstallationProcessStep = .presentingSearchResults
            }
    }
}
