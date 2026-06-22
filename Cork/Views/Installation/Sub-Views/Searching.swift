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
    let packageRequested: String

    @Environment(PackageInstallationProcessStepTracker.self) var packageInstallationProcessStepTracker

    var body: some View
    {
        ProgressView("add-package.searching-\(packageRequested)")
            .task
            {
                async let foundFormulaeNames: [String] = searchForPackage(packageName: packageRequested, packageType: .formula)
                async let foundCasksNames: [String] = searchForPackage(packageName: packageRequested, packageType: .cask)
                
                let foundFormulae: [MinimalHomebrewPackage] = await foundFormulaeNames.map { formulaName in
                    return MinimalHomebrewPackage(
                        name: formulaName,
                        type: .formula,
                        installedIntentionally: false
                    )
                }
                
                let foundCasks: [MinimalHomebrewPackage] = await foundCasksNames.map { caskName in
                    return .init(
                        name: caskName,
                        type: .cask,
                        installedIntentionally: false
                    )
                }

                packageInstallationProcessStepTracker.advanceStep(to: .presentingSearchResults(
                    forSearchString: packageRequested,
                    foundFormulae: foundFormulae,
                    foundCasks: foundCasks
                ))
            }
    }
}
