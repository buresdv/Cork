//
//  Presenting Search Results.swift
//  Cork
//
//  Created by David Bureš on 29.09.2023.
//

import CorkModels
import CorkShared
import FactoryKit
import SwiftUI

struct PresentingSearchResultsView: View
{
    @Environment(\.dismiss) var dismiss: DismissAction
    @Environment(\.openWindow) var openWindow: OpenWindowAction

    @InjectedObservable(\.appState) var appState: AppState

    @Environment(PackageInstallationProcessStepTracker.self) var packageInstallationProcessStepTracker
    
    @State private var searchString: String = ""
    
    @Binding var selectedPackage: MinimalHomebrewPackage?
    
    let foundFormulae: [MinimalHomebrewPackage]
    let foundCasks: [MinimalHomebrewPackage]

    @State private var isFormulaeSectionCollapsed: Bool = false
    @State private var isCasksSectionCollapsed: Bool = false

    @State var isSearchFieldFocused: Bool = true
    
    init(
        oldSearchString: String,
        selectedPackage: Binding<MinimalHomebrewPackage?> = .constant(nil),
        foundFormulae: [MinimalHomebrewPackage],
        foundCasks: [MinimalHomebrewPackage]
    ) {
        _searchString = State(initialValue: oldSearchString)
        _selectedPackage = selectedPackage
        self.foundFormulae = foundFormulae
        self.foundCasks = foundCasks
    }

    var wereAnyPackagesFound: Bool
    {
        if foundFormulae.isEmpty && foundCasks.isEmpty
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
            List(selection: $selectedPackage)
            {
                if !wereAnyPackagesFound
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
                    SearchResultsSection(
                        sectionType: .formula,
                        packageList: foundFormulae
                    )

                    SearchResultsSection(
                        sectionType: .cask,
                        packageList: foundCasks
                    )
                }
            }
            .listStyle(.bordered(alternatesRowBackgrounds: true))
            .frame(minHeight: 200)

            InstallProcessCustomSearchField(search: $searchString, isFocused: $isSearchFieldFocused, customPromptText: String(localized: "add-package.search.prompt"))
            {
                selectedPackage = nil // Clear all selected items when the user looks for a different package
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
    var previewPackageButton: some View
    {
        PreviewPackageButtonWithCustomAction
        {
            guard let selectedPackage = selectedPackage
            else
            {
                AppConstants.shared.logger.error("Failed to preview package")

                return
            }
            openWindow(value: selectedPackage)

            AppConstants.shared.logger.debug("Would preview package \(selectedPackage.name)")
        }
        .disabled(selectedPackage == nil)
        .labelStyle(.titleOnly)
    }

    @ViewBuilder
    var searchForPackageButton: some View
    {
        Button
        {
            packageInstallationProcessStepTracker.advanceStep(to: .searching(forSearchString: searchString))
        } label: {
            Text("add-package.search.action")
        }
        .keyboardShortcut(.defaultAction)
        .disabled(searchString.isEmpty || !isSearchFieldFocused)
    }

    @ViewBuilder
    var startInstallProcessButton: some View
    {
        Button
        {
            if let selectedPackage
            {
                packageInstallationProcessStepTracker.advanceStep(to: .installing(package: selectedPackage))
            }
            else
            {
                AppConstants.shared.logger.error("Impossible case")
            }
            
        } label: {
            Text("add-package.install.action")
        }
        .keyboardShortcut(.defaultAction)
        .disabled(selectedPackage == nil)
    }

    @ViewBuilder
    var restartSearchButton: some View
    {
        Button
        {
            packageInstallationProcessStepTracker.advanceStep(to: .ready)
        } label: {
            Text("action.search-again")
        }
    }
}

private struct SearchResultsSection: View
{
    let sectionType: BrewPackage.PackageType

    let packageList: [MinimalHomebrewPackage]

    @State private var isSectionCollapsed: Bool = false

    var body: some View
    {
        if packageList.isEmpty
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
    private var searchFailed: some View
    {
        InlineContentUnavailableView(
            label: "add-package.search.failed",
            image: "magnifyingglass"
        )
    }
}
