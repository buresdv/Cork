//
//  Initial View.swift
//  Cork
//
//  Created by David Bureš on 20.08.2023.
//

import SwiftUI
import CorkShared

struct InstallationInitialView: View
{
    @Environment(\.dismiss) var dismiss: DismissAction

    @AppStorage("enableDiscoverability") var enableDiscoverability: Bool = false
    @AppStorage("discoverabilityDaySpan") var discoverabilityDaySpan: DiscoverabilityDaySpans = .month

    @EnvironmentObject var appState: AppState

    @EnvironmentObject var brewData: BrewDataStorage

    @EnvironmentObject var topPackagesTracker: TopPackagesTracker

    @ObservedObject var searchResultTracker: SearchResultTracker

    @State private var isTopFormulaeSectionCollapsed: Bool = false
    @State private var isTopCasksSectionCollapsed: Bool = false

    @Binding var packageRequested: String

    @Binding var foundPackageSelection: UUID?

    @ObservedObject var installationProgressTracker: InstallationProgressTracker

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
                        TopPackagesSection(packageTracker: topPackagesTracker.sortedTopFormulae, trackerType: .formula)

                        TopPackagesSection(packageTracker: topPackagesTracker.sortedTopCasks, trackerType: .cask)
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

            HStack
            {
                DismissSheetButton()

                Spacer()

                if enableDiscoverability
                {
                    Button
                    {
                        if let foundPackageSelection
                        {
                            AppConstants.logger.debug("Would install package \(foundPackageSelection)")

                            let topCasksSet: Set<TopPackage> = Set(topPackagesTracker.topCasks)

                            var selectedTopPackageType: PackageType
                            {
                                // If this UUID is in the top casks tracker, it means it's a cask. Otherwise, it's a formula. So we test if the result of looking for the selected package in the cask tracker returns nothing; if it does return nothing, it's a formula (since the package is not in the cask tracker)
                                if topCasksSet.filter({ $0.id == foundPackageSelection }).isEmpty
                                {
                                    return .formula
                                }
                                else
                                {
                                    return .cask
                                }
                            }

                            do
                            {
                                let packageToInstall: BrewPackage = try getTopPackageFromUUID(requestedPackageUUID: foundPackageSelection, packageType: selectedTopPackageType, topPackageTracker: topPackagesTracker)

                                installationProgressTracker.packageBeingInstalled = PackageInProgressOfBeingInstalled(package: packageToInstall, installationStage: .ready, packageInstallationProgress: 0)

                                AppConstants.logger.debug("Packages to install: \(installationProgressTracker.packageBeingInstalled.package.name, privacy: .public)")

                                packageInstallationProcessStep = .installing
                            }
                            catch let topPackageInstallationError
                            {
                                AppConstants.logger.error("Failed while trying to get top package to install: \(topPackageInstallationError, privacy: .public)")

                                dismiss()

                                appState.showAlert(errorToShow: .topPackageArrayFilterCouldNotRetrieveAnyPackages)
                            }
                        }
                        else
                        {
                            AppConstants.logger.warning("Could not find the UUID in the package list")
                            // appState.showAlert(errorToShow: .couldNotFindPackageUUIDInList)
                        }
                    } label: {
                        Text("add-package.install.action")
                    }
                    .keyboardShortcut(foundPackageSelection != nil ? .defaultAction : .init(.end))
                    .disabled(foundPackageSelection == nil)
                }

                Button
                {
                    packageInstallationProcessStep = .searching
                } label: {
                    Text("add-package.search.action")
                }
                .keyboardShortcut(foundPackageSelection == nil ? .defaultAction : .init(.end))
                .disabled(packageRequested.isEmpty)
            }
        }
        .onAppear
        {
            foundPackageSelection = nil
        }
    }
}
