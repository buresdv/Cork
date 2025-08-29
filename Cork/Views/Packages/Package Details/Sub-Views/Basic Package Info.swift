//
//  Basic Package Info.swift
//  Cork
//
//  Created by David Bureš on 26.09.2023.
//

import CorkShared
import Defaults
import SwiftUI

struct BasicPackageInfoView: View
{
    @Default(.caveatDisplayOptions) var caveatDisplayOptions: PackageCaveatDisplay

    let package: BrewPackage
    let packageDetails: BrewPackageDetails

    let isLoadingDetails: Bool

    let isInPreviewWindow: Bool

    @Binding var isShowingExpandedCaveats: Bool

    var hasNotes: Bool
    {
        if packageDetails.caveats != nil
        {
            return true
        }

        if packageDetails.deprecated
        {
            return true
        }

        return false
    }

    var shouldShowNotesSection: Bool
    {
        if self.hasNotes && caveatDisplayOptions == .full
        {
            return true
        }
        else
        {
            return false
        }
    }

    var body: some View
    {
        Section
        {
            Section {}
        } header: {
            PackageDetailHeaderComplex(
                package: package,
                isInPreviewWindow: isInPreviewWindow,
                packageDetails: packageDetails,
                isLoadingDetails: isLoadingDetails
            )
        }
        .padding(.bottom, -15)

        if shouldShowNotesSection
        {
            Section
            {
                Section
                {
                    PackageDeprecationViewFullDisplay(
                        isDeprecated: packageDetails.deprecated,
                        deprecationReason: packageDetails.deprecationReason
                    )
                }

                Section
                {
                    PackageCaveatFullDisplayView(
                        caveats: packageDetails.caveats,
                        isShowingExpandedCaveats: $isShowingExpandedCaveats
                    )
                }
            } header: {
                Text("package-details.notes")
            }
        }

        Section
        {
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
            Text("package-details.info")
        }
    }
}
