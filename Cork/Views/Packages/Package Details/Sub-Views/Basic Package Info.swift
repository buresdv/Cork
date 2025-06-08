//
//  Basic Package Info.swift
//  Cork
//
//  Created by David Bureš on 26.09.2023.
//

import SwiftUI

struct BasicPackageInfoView: View
{
    @AppStorage("caveatDisplayOptions") var caveatDisplayOptions: PackageCaveatDisplay = .full

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
                VStack(alignment: .leading, spacing: 25)
                {
                    PackageDetailHeaderComplex(
                        package: package,
                        isInPreviewWindow: isInPreviewWindow,
                        packageDetails: packageDetails,
                        isLoadingDetails: isLoadingDetails
                    )

                    Text("package-details.notes")
                }
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
            VStack(alignment: .leading, spacing: 25)
            {
                if !shouldShowNotesSection
                {
                    PackageDetailHeaderComplex(
                        package: package,
                        isInPreviewWindow: isInPreviewWindow,
                        packageDetails: packageDetails,
                        isLoadingDetails: isLoadingDetails
                    )
                }

                Text("package-details.info")
            }
        }
    }
}
