//
//  Presenting Search Results.swift
//  Cork
//
//  Created by David Bureš on 29.09.2023.
//

import CorkShared
import SwiftUI

struct PresentingSearchResultsView: View
{
    @Environment(\.dismiss) var dismiss: DismissAction
    @Environment(\.openWindow) var openWindow: OpenWindowAction

    @EnvironmentObject var appState: AppState

    @ObservedObject var searchResultTracker: SearchResultTracker

    @Binding var packageRequested: String
    @Binding var foundPackageSelection: UUID?

    @Binding var packageInstallationProcessStep: PackageInstallationProcessSteps

    @ObservedObject var installationProgressTracker: InstallationProgressTracker

    @State private var isFormulaeSectionCollapsed: Bool = false
    @State private var isCasksSectionCollapsed: Bool = false

    @State var isSearchFieldFocused: Bool = true

    var body: some View
    {
        VStack
        {
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
            .frame(minHeight: 200)

            InstallProcessCustomSearchField(search: $packageRequested, isFocused: $isSearchFieldFocused, customPromptText: String(localized: "add-package.search.prompt"))
            {
                foundPackageSelection = nil // Clear all selected items when the user looks for a different package
            }
        }
        .toolbar
        {
            ToolbarItem(placement: .primaryAction)
            {
                searchForPackageButton
            }
            
            ToolbarItem(placement: .primaryAction) {
                startInstallProcessButton
            }
            
            ToolbarItemGroup(placement: .automatic)
            {
                previewPackageButton
                
                startInstallProcessButton
            }
        }
    }

    @ViewBuilder
    var previewPackageButton: some View
    {
        PreviewPackageButtonWithCustomAction
        {
            do
            {
                let requestedPackageToPreview: BrewPackage = try foundPackageSelection!.getPackage(tracker: searchResultTracker)

                openWindow(value: requestedPackageToPreview)

                AppConstants.shared.logger.debug("Would preview package \(requestedPackageToPreview.name)")
            }
            catch {}
        }
        .disabled(foundPackageSelection == nil)
    }
    
    @ViewBuilder
    var searchForPackageButton: some View
    {
        Button
        {
            packageInstallationProcessStep = .searching
        } label: {
            Text("add-package.search.action")
        }
        .keyboardShortcut(.defaultAction)
        .disabled(packageRequested.isEmpty || !isSearchFieldFocused)
    }
    
    @ViewBuilder
    var startInstallProcessButton: some View
    {
        Button
        {
            getRequestedPackages()

            packageInstallationProcessStep = .installing
        } label: {
            Text("add-package.install.action")
        }
        .keyboardShortcut(.defaultAction)
        .disabled(foundPackageSelection == nil)
    }
    
    private func getRequestedPackages()
    {
        if let foundPackageSelection
        {
            do
            {
                let packageToInstall: BrewPackage = try foundPackageSelection.getPackage(tracker: searchResultTracker)

                installationProgressTracker.packageBeingInstalled = PackageInProgressOfBeingInstalled(package: packageToInstall, installationStage: .ready, packageInstallationProgress: 0)

                #if DEBUG
                    AppConstants.shared.logger.info("Packages to install: \(installationProgressTracker.packageBeingInstalled.package.name, privacy: .public)")
                #endif
            }
            catch let packageByUUIDRetrievalError
            {
                #if DEBUG
                    AppConstants.shared.logger.error("Failed while associating package with its ID: \(packageByUUIDRetrievalError, privacy: .public)")
                #endif

                dismiss()

                appState.showAlert(errorToShow: .couldNotAssociateAnyPackageWithProvidedPackageUUID)
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
                    SearchResultRow(searchedForPackage: package)
                }
            }
        } header: {
            CollapsibleSectionHeader(headerText: sectionType == .formula ? "add-package.search.results.formulae" : "add-package.search.results.casks", isCollapsed: $isSectionCollapsed)
        }
    }
}
