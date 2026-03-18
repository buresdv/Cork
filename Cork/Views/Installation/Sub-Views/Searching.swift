//
//  Searching View.swift
//  Cork
//
//  Created by David Bureš on 20.08.2023.
//

import SwiftUI
import CorkModels

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

                async let foundFormulae: [String]? = searchForPackage(packageName: packageRequested, packageType: .formula)
                async let foundCasks: [String]? = searchForPackage(packageName: packageRequested, packageType: .cask)

                if let foundFormulae = await foundFormulae, let foundCasks = await foundCasks
                {
                    for foundPackageName in foundFormulae {
                        searchResultTracker.foundFormulae?.append(
                            .init(
                                minimalPackageFromName: foundPackageName,
                                type: .formula
                            )
                        )
                    }
                    
                    for foundPackageName in foundCasks {
                        searchResultTracker.foundCasks?.append(
                            .init(
                                minimalPackageFromName: foundPackageName,
                                type: .cask
                            )
                        )
                    }
                }

                packageInstallationProcessStep = .presentingSearchResults
            }
    }
}
