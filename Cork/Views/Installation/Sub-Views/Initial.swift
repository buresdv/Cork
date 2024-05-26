//
//  Initial View.swift
//  Cork
//
//  Created by David Bureš on 20.08.2023.
//

import SwiftUI

struct InstallationInitialView: View
{
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("enableDiscoverability") var enableDiscoverability: Bool = false
    @AppStorage("discoverabilityDaySpan") var discoverabilityDaySpan: DiscoverabilityDaySpans = .month

    @EnvironmentObject var appState: AppState
    
    @EnvironmentObject var brewData: BrewDataStorage

    @EnvironmentObject var topPackagesTracker: TopPackagesTracker
    
    @ObservedObject var searchResultTracker: SearchResultTracker

    @State private var isTopFormulaeSectionCollapsed: Bool = false
    @State private var isTopCasksSectionCollapsed: Bool = false

    @Binding var packageRequested: String

    @Binding var foundPackageSelection: Set<UUID>

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
                        TopPackagesSection(packageTracker: topPackagesTracker.topFormulae, isCaskTracker: false)

                        TopPackagesSection(packageTracker: topPackagesTracker.topCasks, isCaskTracker: true)
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
            
            InstallProcessCustomSearchField(search: $packageRequested, isFocused: $isSearchFieldFocused, customPromptText: String(localized: "add-package.search.prompt")) {
                foundPackageSelection = Set<UUID>() // Clear all selected items when the user looks for a different package
            }

            HStack
            {
                DismissSheetButton()

                Spacer()

                if enableDiscoverability
                {
                    Button
                    {
                        AppConstants.logger.debug("Would install package \(foundPackageSelection)")
                        
                        let topCasksSet = Set(topPackagesTracker.topCasks)
                        
                        var selectedTopPackageIsCask: Bool
                        {
                            // If this UUID is in the top casks tracker, it means it's a cask. Otherwise, it's a formula. So we test if the result of looking for the selected package in the cask tracker returns nothing; if it does return nothing, it's a formula (since the package is not in the cask tracker)
                            if topCasksSet.filter({ $0.id == foundPackageSelection.first }).isEmpty
                            {
                                return false
                            }
                            else
                            {
                                return true
                            }
                        }
                        
                        do
                        {
                            let packageToInstall: BrewPackage = try getTopPackageFromUUID(requestedPackageUUID: foundPackageSelection.first!, isCask: selectedTopPackageIsCask, topPackageTracker: topPackagesTracker)
                            
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
                        
                    } label: {
                        Text("add-package.install.action")
                    }
                    .keyboardShortcut(!foundPackageSelection.isEmpty ? .defaultAction : .init(.end))
                    .disabled(foundPackageSelection.isEmpty)
                }

                Button
                {
                    packageInstallationProcessStep = .searching
                } label: {
                    Text("add-package.search.action")
                }
                .keyboardShortcut(foundPackageSelection.isEmpty ? .defaultAction : .init(.end))
                .disabled(packageRequested.isEmpty)
            }
        }
        .onAppear
        {
            foundPackageSelection = .init()
        }
    }
}
