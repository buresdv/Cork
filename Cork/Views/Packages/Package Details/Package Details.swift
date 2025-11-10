//
//  Package Details.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import CorkShared
import SwiftUI
import CorkModels
import ApplicationInspector

struct PackageDetailView: View, Sendable, DismissablePane
{
    let package: BrewPackage

    /// We need to create a reference to this package in brewPackagesTracker so that the UI can observe changes in it
    private var dynamicPackage: BrewPackage?
    {
        return brewPackagesTracker.checkForDynamicPackage(passedInPackage: package)
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
                
                dismissPane()
            }
            
            return package
        }
    }

    var isInPreviewWindow: Bool = false

    @State private var packageDetails: BrewPackage.BrewPackageDetails? = nil
    
    @State private var caskExecutable: Application? = nil

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

                        PackageDependencies(
                            dependencies: packageDetails?.dependencies,
                            isDependencyDisclosureGroupExpanded: $isShowingExpandedDependencies
                        )

                        PackageSystemInfo(
                            package: packageStructureToUse,
                            caskExecutable: caskExecutable
                        )
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
                    /*
                    Button
                    {
                        dismissPane()
                    } label: {
                        Label("DEBUG: Dismiss yourself", systemImage: "xmark")
                    }
                     */
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
        .task(id: package.id)
        { // For casks, try to load the application executable
            if package.type == .cask
            {
                AppConstants.shared.logger.info("Package is cask, will see what the app's location is for url \(package.url as NSObject?)")
                
                if let packageURL = package.url
                {
                    AppConstants.shared.logger.info("Will try to load app icon for URL \(packageURL)")
                    caskExecutable = try? .init(from: packageURL)
                }
            }
        }
    }
}

private extension BrewPackagesTracker
{
    func checkForDynamicPackage(passedInPackage package: BrewPackage) -> BrewPackage?
    {
        // MARK: - Finding the package using IDs
        if let packageFoundByID = self.checkForDynamicPackageByID(passedInPackage: package)
        {
            AppConstants.shared.logger.debug("Will try to find package in tracker by ID")
            
            return packageFoundByID
        }
        else
        {
            AppConstants.shared.logger.debug("First round of checking using IDs did not return any packages. Will try again using select package properties a hash.")
            
            if let packageFoundByHashableRepresentation = self.checkForDynamicPackageByMinimalHashableRepresentation(passedInPackage: package)
            {
                return packageFoundByHashableRepresentation
            }
            else
            {
                AppConstants.shared.logger.debug("""
        Did not find any packages in tracker with the matching ID. Expected ID: \(package.id).
        List of IDs of installed Formulae: \(self.successfullyLoadedFormulae.map{ $0.id })
        List of IDs of installed Casks: \(self.successfullyLoadedCasks.map{ $0.id })
        """)
                
                return nil
            }
        }
    }
    
    func checkForDynamicPackageByID(passedInPackage package: BrewPackage) -> BrewPackage?
    {
        if let possibleFormula: BrewPackage = self.successfullyLoadedFormulae.filter({ $0.id == package.id }).first
        {
            AppConstants.shared.logger.debug("Found the correct formula: \(possibleFormula.name), ID: \(possibleFormula.id)")
            
            return possibleFormula
        }

        if let possibleCask: BrewPackage = self.successfullyLoadedCasks.filter({ $0.id == package.id }).first
        {
            AppConstants.shared.logger.debug("Found the correct cask: \(possibleCask.name), ID: \(possibleCask.id)")
            
            return possibleCask
        }
        
        return nil
    }
    
    func checkForDynamicPackageByMinimalHashableRepresentation(passedInPackage package: BrewPackage) -> BrewPackage?
    {
        /// Representation of selected package parameters for comparing equality, based on something other than the package ID
        struct FastPackageComparableRepresentation: Hashable
        {
            let name: String
            let type: BrewPackage.PackageType
            let versions: [String]
            
            init(name: String, type: BrewPackage.PackageType, versions: [String])
            {
                self.name = name
                self.type = type
                self.versions = versions
            }
            
            /// Initialize the fast comparable representation from a ``BrewPackage``
            init(from brewPackage: BrewPackage)
            {
                self.init(name: brewPackage.name, type: brewPackage.type, versions: brewPackage.versions)
            }
        }
        
        let hashOfSearchedForPackage: FastPackageComparableRepresentation = .init(from: package)
        
        if let possibleFormula: BrewPackage = self.successfullyLoadedFormulae.filter({ FastPackageComparableRepresentation(from: $0) == hashOfSearchedForPackage }).first
        {
            AppConstants.shared.logger.debug("Found the correct Formula using hashing: \(possibleFormula.name), ID: \(possibleFormula.id)")
            return possibleFormula
        }
        
        if let possibleCask: BrewPackage = self.successfullyLoadedCasks.filter({ FastPackageComparableRepresentation(from: $0) == hashOfSearchedForPackage }).first
        {
            AppConstants.shared.logger.debug("Found the correct Cask using hashing: \(possibleCask.name), ID: \(possibleCask.id)")
            
            return possibleCask
        }
        
        return nil
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
