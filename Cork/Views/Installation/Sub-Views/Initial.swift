//
//  Initial View.swift
//  Cork
//
//  Created by David Bureš on 20.08.2023.
//

import SwiftUI
import CorkShared
import Defaults
import CorkModels
import FactoryKit

struct InstallationInitialView: View
{
    @Environment(\.dismiss) var dismiss: DismissAction
    @Environment(\.openWindow) var openWindow: OpenWindowAction

    @Default(.enableDiscoverability) var enableDiscoverability: Bool
    @Default(.discoverabilityDaySpan) var discoverabilityDaySpan: DiscoverabilityDaySpans

    @InjectedObservable(\.appState) var appState: AppState

    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker

    @Environment(TopPackagesTracker.self) var topPackagesTracker: TopPackagesTracker

    @State private var isTopFormulaeSectionCollapsed: Bool = false
    @State private var isTopCasksSectionCollapsed: Bool = false

    @Binding var packageRequested: String

    @Binding var foundPackageSelection: BrewPackage?

    let packageToInstall: MinimalHomebrewPackage

    @Binding var packageInstallationProcessStep: PackageInstallationProcessSteps

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
                ToolbarItemGroup(placement: .automatic)
                {
                    previewPackageButton
                    
                    startInstallProcessForTopPackageButton
                }
            }
            
            ToolbarItem(placement: .primaryAction)
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
    var previewPackageButton: some View
    {
        PreviewPackageButtonWithCustomAction
        {
            guard let packageToPreview: BrewPackage = foundPackageSelection else
            {
                AppConstants.shared.logger.error("Could not retrieve top package to preview")
                
                return
            }
            
            openWindow(value: MinimalHomebrewPackage(
                name: packageToPreview.name(withPrecision: .precise),
                type: packageToPreview.type,
                installedIntentionally: packageToPreview.installedIntentionally
            ))
        }
        .disabled(foundPackageSelection == nil)
        .labelStyle(.titleOnly)
    }
    
    @ViewBuilder
    var startInstallProcessForTopPackageButton: some View
    {
        Button
        {
            guard let packageToInstall: BrewPackage = foundPackageSelection else
            {
                AppConstants.shared.logger.error("Could not retrieve top package to install")
                
                return
            }
            
            packageInstallationProcessStep = .installing(
                package: .init(
                    name: packageToInstall.name(withPrecision: .precise),
                    type: packageToInstall.type,
                    installedIntentionally: false
                )
            )
            
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
            packageInstallationProcessStep = .searching(forSearchString: packageRequested)
        } label: {
            Text("add-package.search.action")
        }
        .keyboardShortcut(foundPackageSelection == nil ? .defaultAction : .init(.end))
        .disabled(packageRequested.isEmpty)
    }
}
