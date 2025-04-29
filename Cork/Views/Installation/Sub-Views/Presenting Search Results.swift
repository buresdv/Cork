//
//  Presenting Search Results.swift
//  Cork
//
//  Created by David Bureš on 29.09.2023.
//

import ButtonKit
import CorkShared
import SwiftUI

struct PresentingSearchResultsView: View
{
    enum PackageInstallationInitializationError: Error
    {
        case couldNotStartInstallProcessWithPackage(package: BrewPackage?)
    }

    @Environment(\.dismiss) var dismiss: DismissAction
    @Environment(\.openWindow) var openWindow: OpenWindowAction

    @EnvironmentObject var appState: AppState

    @ObservedObject var searchResultTracker: SearchResultTracker

    @Binding var packageRequested: String
    @Binding var foundPackageSelection: AddFormulaView.PackageSelectedToBeInstalled?

    @Binding var packageInstallationProcessStep: PackageInstallationProcessSteps

    @ObservedObject var installationProgressTracker: InstallationProgressTracker

    @State private var isFormulaeSectionCollapsed: Bool = false
    @State private var isCasksSectionCollapsed: Bool = false

    @State var isSearchFieldFocused: Bool = true

    var wereAnyPackagesFound: Bool
    {
        if searchResultTracker.foundFormulae.isEmpty && searchResultTracker.foundCasks.isEmpty
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
        VStack
        {
            List(selection: $foundPackageSelection)
            {
                if !wereAnyPackagesFound
                {
                    noPackagesFoundStates
                }
                else
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

            ToolbarItem(placement: .primaryAction)
            {
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
    var noPackagesFoundStates: some View
    {
        if #available(macOS 14.0, *)
        {
            ContentUnavailableView
            {
                Label("add-package.search.results.packages.none-found", image: "custom.shippingbox.badge.magnifyingglass")
            } description: {
                Text("add.package.search.results.packages.none-found.description")
            } actions: {
                EmptyView()
            }
        }
        else
        {
            VStack(alignment: .center, spacing: 5)
            {
                Text("add-package.search.results.packages.none-found")

                restartSearchButton
            }
        }
    }

    @ViewBuilder
    var previewPackageButton: some View
    {
        PreviewPackageButtonWithCustomAction
        {
            guard let selectedPackage: AddFormulaView.PackageSelectedToBeInstalled = foundPackageSelection
            else
            {
                AppConstants.shared.logger.error("Failed to preview package")

                return
            }
            
            openWindow(value: selectedPackage)
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
        // This has to be an AsyncButton so it shakes
        AsyncButton
        {
            guard let packageToInstall = foundPackageSelection?.package
            else
            {
                throw PackageInstallationInitializationError.couldNotStartInstallProcessWithPackage(package: nil)
            }

            packageInstallationProcessStep = .installing(packageToInstall: packageToInstall)
        } label: {
            Text("add-package.install.action")
        }
        .throwableButtonStyle(.shake)
        .keyboardShortcut(.defaultAction)
        .disabled(foundPackageSelection == nil)
    }

    @ViewBuilder
    var restartSearchButton: some View
    {
        Button
        {
            packageInstallationProcessStep = .ready
        } label: {
            Text("action.search-again")
        }
    }
}

private struct SearchResultsSection: View
{
    let sectionType: PackageType

    let packageList: [BrewPackage]

    @State private var isSectionCollapsed: Bool = false

    var body: some View
    {
        if packageList.isEmpty
        {
            noPackagesFoundStates
        }
        else
        {
            Section
            {
                if !isSectionCollapsed
                {
                    ForEach(packageList)
                    { package in
                        SearchResultRow(searchedForPackage: package, context: .searchResults)
                    }
                }
            } header: {
                CollapsibleSectionHeader(headerText: sectionType == .formula ? "add-package.search.results.formulae" : "add-package.search.results.casks", isCollapsed: $isSectionCollapsed)
            }
        }
    }

    @ViewBuilder
    var noPackagesFoundStates: some View
    {
        Group
        {
            if #available(macOS 14.0, *)
            {
                switch sectionType
                {
                case .formula:
                    SmallerContentUnavailableView(label: "add-package.search.results.formulae.none-found", image: "custom.apple.terminal.badge.magnifyingglass")
                case .cask:
                    SmallerContentUnavailableView(label: "add-package.search.results.casks.none-found", image: "custom.macwindow.badge.magnifyingglass")
                }
            }
            else
            {
                switch sectionType
                {
                case .formula:
                    Text("add-package.search.results.formulae.none-found")
                case .cask:
                    Text("add-package.search.results.casks.none-found")
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
    }
}
