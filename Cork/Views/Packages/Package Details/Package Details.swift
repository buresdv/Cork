//
//  Package Details.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import CorkShared
import SwiftUI

struct PackageDetailView: View, Sendable
{
    @Environment(\.dismiss) var dismiss: DismissAction
    
    let package: BrewPackage

    /// We need to create a reference to this package in brewData so that the UI can observe changes in it
    private var dynamicPackage: BrewPackage?
    {
        if let possibleFormula: BrewPackage = brewData.successfullyLoadedFormulae.filter({ $0.id == package.id }).first
        {
            return possibleFormula
        }

        if let possibleCask: BrewPackage = brewData.successfullyLoadedCasks.filter({ $0.id == package.id }).first
        {
            return possibleCask
        }

        dismiss()
        
        return nil
    }

    var isInPreviewWindow: Bool = false

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

    var body: some View
    {
        let packageToDisplay = dynamicPackage ?? package
        
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
                            package: packageToDisplay,
                            packageDetails: packageDetails!,
                            isLoadingDetails: isLoadingDetails,
                            isInPreviewWindow: isInPreviewWindow,
                            isShowingExpandedCaveats: $isShowingExpandedCaveats
                        )

                        PackageDependencies(dependencies: packageDetails?.dependencies, isDependencyDisclosureGroupExpanded: $isShowingExpandedDependencies)

                        PackageSystemInfo(package: packageToDisplay)
                    }
                }
            }

            Spacer()

            if !isInPreviewWindow
            {
                if packageDetails != nil
                {
                    PackageModificationButtons(
                        package: packageToDisplay,
                        packageDetails: packageDetails!,
                        isLoadingDetails: isLoadingDetails
                    )
                }
            }
        }
        .frame(minWidth: 450, minHeight: 400, alignment: .topLeading)
        .task(id: package.id)
        {
            isLoadingDetails = true
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
                AppConstants.shared.logger.error("Failed while parsing package info: \(packageInfoDecodingError, privacy: .public)")

                erroredOut = (true, packageInfoDecodingError.localizedDescription)
            }
        }
    }
}

extension PackageDetailView
{
    func isPreview() -> PackageDetailView
    {
        var modifiedView: PackageDetailView = self
        modifiedView.isInPreviewWindow = true
        return modifiedView
    }
}
