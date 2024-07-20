//
//  Package Details.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI

struct PackageDetailView: View, Sendable
{
    let package: BrewPackage
    
    @State private var packageDetails: BrewPackageDetails? = nil

    @EnvironmentObject var brewData: BrewDataStorage

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker
    
    @State private var isShowingExpandedDependencies: Bool = false
    @State private var isShowingExpandedCaveats: Bool = false

    @State private var isLoadingDetails: Bool = true
    @State private var hasFailedWhileLoadingDependents: Bool = false

    @State var isShowingPopover: Bool = false

    @State private var erroredOut: (isShowingError: Bool, errorDescription: String?) = (false, nil)

    private var isScrollingDisabled: Bool
    {
        if isShowingExpandedCaveats
        {
            return false
        }
        else if isShowingExpandedDependencies
        {
            return false
        }
        else
        {
            return true
        }
    }

    var body: some View
    {
        VStack(alignment: .leading, spacing: 0)
        {
            if isLoadingDetails
            {
                HStack(alignment: .center)
                {
                    VStack(alignment: .center)
                    {
                        ProgressView
                        {
                            Text("package-details.contents.loading")
                        }
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
            else
            {
                if erroredOut.isShowingError
                {
                    InlineFatalError(errorMessage: "error.generic.unexpected-homebrew-response", errorDescription: erroredOut.errorDescription)
                }
                else
                {
                    FullSizeGroupedForm
                    {
                        BasicPackageInfoView(
                            package: package,
                            packageDetails: packageDetails!,
                            isLoadingDetails: isLoadingDetails,
                            isShowingExpandedCaveats: $isShowingExpandedCaveats
                        )

                        PackageDependencies(dependencies: packageDetails?.dependencies, isDependencyDisclosureGroupExpanded: $isShowingExpandedDependencies)

                        PackageSystemInfo(package: package)
                    }
                    .scrollDisabled(isScrollingDisabled)
                }
            }

            Spacer()

            if packageDetails != nil
            {
                PackageModificationButtons(
                    package: package,
                    packageDetails: packageDetails!,
                    isLoadingDetails: isLoadingDetails
                )
            }
             
        }
        .frame(minWidth: 450, minHeight: 400, alignment: .topLeading)
        .task(priority: .userInitiated)
        {
            defer
            {
                if isLoadingDetails
                {
                    isLoadingDetails = false
                }
            }

            do
            {
                packageDetails = try await package.loadDetails()

                isLoadingDetails = false

                if let packageDetails
                {
                    if packageDetails.installedAsDependency
                    {
                        await packageDetails.loadDependents()
                    }
                }
            }
            catch let packageInfoDecodingError
            {
                AppConstants.logger.error("Failed while parsing package info: \(packageInfoDecodingError, privacy: .public)")

                erroredOut = (true, packageInfoDecodingError.localizedDescription)
            }
        }
    }
}
