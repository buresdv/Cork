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
    let packageDetails: BrewPackageDetails

    let isLoadingDetails: Bool

    @Binding var isShowingExpandedCaveats: Bool

    var body: some View
    {
        Section
        {
            PackageCaveatFullDisplayView(caveats: packageDetails.caveats, isShowingExpandedCaveats: $isShowingExpandedCaveats)

            LabeledContent
            {
                Text(packageDetails.tap.name)
            } label: {
                Text("Tap")
            }

            LabeledContent
            {
                Text(package.type.displayRepresentation.title)
            } label: {
                Text("package-details.type")
            }

            LabeledContent
            {
                Link(destination: packageDetails.homepage)
                {
                    Text(packageDetails.homepage.absoluteString)
                }
            } label: {
                Text("package-details.homepage")
            }
        } header: {
            VStack(alignment: .leading, spacing: 15)
            {
                PackageDetailHeaderComplex(
                    package: package,
                    packageDetails: packageDetails,
                    isLoadingDetails: isLoadingDetails
                )

                Text("package-details.info")
                    .font(.title2)
            }
        }
    }
}
