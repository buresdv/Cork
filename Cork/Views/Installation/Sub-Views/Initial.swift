//
//  Initial View.swift
//  Cork
//
//  Created by David Bureš on 20.08.2023.
//

import CorkModels
import CorkShared
import Defaults
import FactoryKit
import SwiftUI

struct InstallationInitialView: View
{
    @Environment(\.dismiss) var dismiss: DismissAction
    @Environment(\.openWindow) var openWindow: OpenWindowAction

    @Default(.enableDiscoverability) var enableDiscoverability: Bool
    @Default(.discoverabilityDaySpan) var discoverabilityDaySpan: DiscoverabilityDaySpans

    @InjectedObservable(\.appState) var appState: AppState

    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker

    @Environment(TopPackagesTracker.self) var topPackagesTracker: TopPackagesTracker

    @Environment(PackageInstallationProcessStepTracker.self) var packageInstallationProcessStepTracker

    @State private var isTopFormulaeSectionCollapsed: Bool = false
    @State private var isTopCasksSectionCollapsed: Bool = false

    @State private var packageRequested: String = ""

    @State private var foundPackageSelection: MinimalHomebrewPackage?

    @State var isSearchFieldFocused: Bool = true

    var body: some View
    {
        VStack
        {
            if enableDiscoverability
            {
                if !topPackagesTracker.topFormulae.isEmpty || !topPackagesTracker.topCasks.isEmpty
                {
                    List(selection: $foundPackageSelection)
                    {
                        TopPackagesSection(packageTracker: topPackagesTracker, trackerType: .formula)

                        TopPackagesSection(packageTracker: topPackagesTracker, trackerType: .cask)
                    }
                    .listStyle(.bordered(alternatesRowBackgrounds: true))
                    .frame(minHeight: 200)
                }
                else
                {
                    if appState.failedWhileLoadingTopPackages
                    {
                        NoContentAvailableView(title: "add-package.error.timed-out.title", systemImage: "exclamationmark.magnifyingglass")
                    }
                    else
                    {
                        ProgressView("Loading top packages…")
                            .frame(minHeight: 200)
                    }
                }
            }

            InstallProcessCustomSearchField(search: $packageRequested, isFocused: $isSearchFieldFocused, customPromptText: String(localized: "add-package.search.prompt"))
            {
                foundPackageSelection = nil // Clear all selected items when the user looks for a different package
            }
        }
        .toolbar
        {
            if enableDiscoverability
            {
                ToolbarItemGroup(placement: .primaryAction)
                {
                    startInstallProcessForTopPackageButton
                }
            }

            ToolbarItem(placement: .automatic)
            {
                searchForPackageButton
            }
        }
        .onAppear
        {
            foundPackageSelection = nil
        }
    }

    @ViewBuilder
    var startInstallProcessForTopPackageButton: some View
    {
        Button
        {
            guard let packageToInstall: MinimalHomebrewPackage = foundPackageSelection
            else
            {
                AppConstants.shared.logger.error("Could not retrieve top package to install")

                return
            }

            packageInstallationProcessStepTracker.advanceStep(to: .installing(package: packageToInstall))

        } label: {
            Text("add-package.install.action")
        }
        .keyboardShortcut(foundPackageSelection != nil ? .defaultAction : .init(.end))
        .disabled(foundPackageSelection == nil)
    }

    @ViewBuilder
    var searchForPackageButton: some View
    {
        Button
        {
            packageInstallationProcessStepTracker.advanceStep(to: .searching(forSearchString: packageRequested))
        } label: {
            Text("add-package.search.action")
        }
        .keyboardShortcut(foundPackageSelection == nil ? .defaultAction : .init(.end))
        .disabled(packageRequested.isEmpty)
    }
}
