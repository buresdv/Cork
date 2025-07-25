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

    /// We need to create a reference to this package in brewPackagesTracker so that the UI can observe changes in it
    private var dynamicPackage: BrewPackage?
    {
        if let possibleFormula: BrewPackage = brewPackagesTracker.successfullyLoadedFormulae.filter({ $0.id == package.id }).first
        {
            return possibleFormula
        }

        if let possibleCask: BrewPackage = brewPackagesTracker.successfullyLoadedCasks.filter({ $0.id == package.id }).first
        {
            return possibleCask
        }
        
        return nil
    }
    
    private var packageStructureToUse: BrewPackage
    {
        if let dynamicPackage
        {
            return dynamicPackage
        }
        else
        {
            if !isInPreviewWindow
            {
                /// This gets tripped when the package that is currently open in the details window gets uninstalled.. In that case, dismiss the detail when the package gets uninstalled.
                
                dismiss()
            }
            
            return package
        }
    }

    var isInPreviewWindow: Bool = false

    @State private var packageDetails: BrewPackageDetails? = nil

    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker

    @Environment(AppState.self) var appState: AppState
    @Environment(OutdatedPackagesTracker.self) var outdatedPackagesTracker: OutdatedPackagesTracker

    @State private var isShowingExpandedDependencies: Bool = false
    @State private var isShowingExpandedCaveats: Bool = false

    @State private var isLoadingDetails: Bool = true
    @State private var hasFailedWhileLoadingDependents: Bool = false

    @State var isShowingPopover: Bool = false

    @State private var erroredOut: (isShowingError: Bool, errorDescription: String?) = (false, nil)

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
                            package: packageStructureToUse,
                            packageDetails: packageDetails!,
                            isLoadingDetails: isLoadingDetails,
                            isInPreviewWindow: isInPreviewWindow,
                            isShowingExpandedCaveats: $isShowingExpandedCaveats
                        )

                        PackageDependencies(dependencies: packageDetails?.dependencies, isDependencyDisclosureGroupExpanded: $isShowingExpandedDependencies)

                        PackageSystemInfo(package: packageStructureToUse)
                    }
                }
            }

            Spacer()

            if !isInPreviewWindow
            {
                if packageDetails != nil
                {
                    PackageModificationButtons(
                        package: packageStructureToUse,
                        packageDetails: packageDetails!,
                        isLoadingDetails: isLoadingDetails
                    )
                    
                    #if DEBUG
                    Button
                    {
                        dismiss()
                    } label: {
                        Label("DEBUG: Dismiss yourself", systemImage: "xmark")
                    }
                    #endif
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
