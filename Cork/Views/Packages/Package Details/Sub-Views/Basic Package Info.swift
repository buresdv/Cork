//
//  Basic Package Info.swift
//  Cork
//
//  Created by David Bureš on 26.09.2023.
//

import SwiftUI

struct BasicPackageInfoView: View
{
    let package: BrewPackage

    let tap: String
    let homepage: URL

    let description: String
    let pinned: Bool
    let installedAsDependency: Bool
    let packageDependents: [String]?
    let outdated: Bool
    let caveats: String?

    let isLoadingDetails: Bool

    @Binding var isShowingExpandedCaveats: Bool

    var body: some View
    {
        Section 
        {
            PackageCaveatFullDisplayView(caveats: caveats, isShowingExpandedCaveats: $isShowingExpandedCaveats)

            LabeledContent {
                Text(tap)
            } label: {
                Text("Tap")
            }

            LabeledContent
            {
                if package.isCask
                {
                    Text("package-details.type.cask")
                }
                else
                {
                    Text("package-details.type.formula")
                }
            } label: {
                Text("package-details.type")
            }

            LabeledContent
            {
                Link(destination: homepage)
                {
                    Text(homepage.absoluteString)
                }
            } label: {
                Text("package-details.homepage")
            }
        } header: {
            VStack(alignment: .leading, spacing: 15)
            {
                PackageDetailHeaderComplex(
                    package: package,
                    description: description,
                    pinned: pinned,
                    installedAsDependency: installedAsDependency,
                    packageDependents: packageDependents,
                    outdated: outdated,
                    caveats: caveats,
                    isLoadingDetails: isLoadingDetails
                )

                Text("package-details.info")
                    .font(.title2)
            }
        }
    }
}
