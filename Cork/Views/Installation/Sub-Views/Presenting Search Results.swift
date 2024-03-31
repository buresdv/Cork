//
//  Presenting Search Results.swift
//  Cork
//
//  Created by David Bureš on 29.09.2023.
//

import SwiftUI


struct PresentingSearchResultsView: View
{
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var appState: AppState

    @ObservedObject var searchResultTracker: SearchResultTracker

    @Binding var packageRequested: String
    @Binding var foundPackageSelection: Set<UUID>

    @Binding var packageInstallationProcessStep: PackageInstallationProcessSteps

    @ObservedObject var installationProgressTracker: InstallationProgressTracker

    @State private var isFormulaeSectionCollapsed: Bool = false
    @State private var isCasksSectionCollapsed: Bool = false

    @FocusState var isSearchFieldFocused: Bool

    var body: some View
    {
        VStack
        {
            TextField("add-package.search.prompt", text: $packageRequested)
            { _ in
                foundPackageSelection = Set<UUID>() // Clear all selected items when the user looks for a different package
            }
            .focused($isSearchFieldFocused)
            .onAppear
            {
                isSearchFieldFocused = true
            }

            List(selection: $foundPackageSelection)
            {
                SearchResultsSection(
                    sectionType: .formula,
                    packageList: searchResultTracker.foundFormulae
                )

                SearchResultsSection(
                    sectionType: .cask,
                    packageList: searchResultTracker.foundCasks
                )
            }
            .listStyle(.bordered(alternatesRowBackgrounds: true))
            .frame(width: 300, height: 300)

            HStack
            {
                DismissSheetButton()

                Spacer()

                if isSearchFieldFocused
                {
                    Button
                    {
                        packageInstallationProcessStep = .searching
                    } label: {
                        Text("add-package.search.action")
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(packageRequested.isEmpty)
                }
                else
                {
                    Button
                    {
                        for requestedPackage in foundPackageSelection
                        {
                            do
                            {
                                let packageToInstall: BrewPackage = try getPackageFromUUID(requestedPackageUUID: requestedPackage, tracker: searchResultTracker)

                                installationProgressTracker.packagesBeingInstalled.append(PackageInProgressOfBeingInstalled(package: packageToInstall, installationStage: .ready, packageInstallationProgress: 0))

                                AppConstants.logger.info("Packages to install: \(installationProgressTracker.packagesBeingInstalled, privacy: .public)")

                                installationProgressTracker.packageBeingCurrentlyInstalled = packageToInstall.name
                            }
                            catch let packageByUUIDRetrievalError
                            {
                                AppConstants.logger.error("Failed while associating package with its ID: \(packageByUUIDRetrievalError, privacy: .public)")
                                
                                dismiss()
                                
                                appState.showAlert(errorToShow: .couldNotAssociateAnyPackageWithProvidedPackageUUID)
                            }
                        }

                        AppConstants.logger.info("\(installationProgressTracker.packagesBeingInstalled, privacy: .public)")

                        packageInstallationProcessStep = .installing
                    } label: {
                        Text("add-package.install.action")
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(foundPackageSelection.isEmpty)
                }
            }
        }
    }
}

private struct SearchResultsSection: View
{
    fileprivate enum SectionType
    {
        case formula, cask
    }

    let sectionType: SectionType

    let packageList: [BrewPackage]

    @State private var isSectionCollapsed: Bool = false

    var body: some View
    {
        Section
        {
            if !isSectionCollapsed
            {
                ForEach(packageList)
                { package in
                    SearchResultRow(packageName: package.name, isCask: package.isCask)
                }
            }
        } header: {
            CollapsibleSectionHeader(headerText: sectionType == .formula ? "add-package.search.results.formulae" : "add-package.search.results.casks", isCollapsed: $isSectionCollapsed)
        }
    }
}
