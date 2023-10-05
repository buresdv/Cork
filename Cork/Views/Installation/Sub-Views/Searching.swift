//
//  Searching View.swift
//  Cork
//
//  Created by David Bureš on 20.08.2023.
//

import SwiftUI

struct InstallationSearchingView: View
{
    @Binding var packageRequested: String

    @ObservedObject var searchResultTracker: SearchResultTracker

    @Binding var packageInstallationProcessStep: PackageInstallationProcessSteps

    var body: some View
    {
        ProgressView("add-package.searching-\(packageRequested)")
            .onAppear
            {
                Task
                {
                    searchResultTracker.foundFormulae = []
                    searchResultTracker.foundCasks = []

                    async let foundFormulae = try searchForPackage(packageName: packageRequested, packageType: .formula)
                    async let foundCasks = try searchForPackage(packageName: packageRequested, packageType: .cask)

                    for formula in try await foundFormulae
                    {
                        searchResultTracker.foundFormulae.append(BrewPackage(name: formula, isCask: false, installedOn: nil, versions: [], sizeInBytes: nil))
                    }
                    for cask in try await foundCasks
                    {
                        searchResultTracker.foundCasks.append(BrewPackage(name: cask, isCask: true, installedOn: nil, versions: [], sizeInBytes: nil))
                    }

                    packageInstallationProcessStep = .presentingSearchResults
                }
            }
    }
}
