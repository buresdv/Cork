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

    @State private var installedFormulaNamesSet: Set<String> = .init()
    @State private var installedCaskNamesSet: Set<String> = .init()

    @State private var isTopFormulaeSectionCollapsed: Bool = false
    @State private var isTopCasksSectionCollapsed: Bool = false

    @Binding var isShowingSheet: Bool
    @Binding var packageRequested: String

    @Binding var foundPackageSelection: Set<UUID>

    @ObservedObject var installationProgressTracker: InstallationProgressTracker
    
    @Binding var packageInstallationProcessStep: PackageInstallationProcessSteps

    @FocusState var isSearchFieldFocused: Bool

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
                        Section
                        {
                            if !isTopFormulaeSectionCollapsed
                            {
                                ForEach(topPackagesTracker.topFormulae.filter
                                {
                                    !installedFormulaNamesSet.contains($0.packageName)
                                }.prefix(15))
                                { topFormula in
                                    TopPackageListItem(topPackage: topFormula)
                                }
                            }
                        } header: {
                            CollapsibleSectionHeader(headerText: "add-package.top-formulae", isCollapsed: $isTopFormulaeSectionCollapsed)
                        }

                        Section
                        {
                            if !isTopCasksSectionCollapsed
                            {
                                ForEach(topPackagesTracker.topCasks.filter
                                {
                                    !installedCaskNamesSet.contains($0.packageName)
                                }.prefix(15))
                                { topCask in
                                    TopPackageListItem(topPackage: topCask)
                                }
                            }
                        } header: {
                            CollapsibleSectionHeader(headerText: "add-package.top-casks", isCollapsed: $isTopCasksSectionCollapsed)
                        }
                    }
                    .listStyle(.bordered(alternatesRowBackgrounds: true))
                    .frame(minHeight: 200)
                    .onAppear
                    {
                        // Convert the installed formular and casks array into sets for faster comparisons
                        installedFormulaNamesSet = Set(brewData.installedFormulae.map(\.name))
                        installedCaskNamesSet = Set(brewData.installedCasks.map(\.name))
                    }
                    .onDisappear
                    {
                        installedFormulaNamesSet = .init()
                        installedCaskNamesSet = .init()
                    }
                }
                else
                {
                    ProgressView("Loading top packages…")
                        .frame(minHeight: 200)
                }
            }

            TextField("add-package.search.prompt", text: $packageRequested)
            { _ in
                foundPackageSelection = Set<UUID>() // Clear all selected items when the user looks for a different package
            }
            .focused($isSearchFieldFocused)
            .onAppear
            {
                isSearchFieldFocused.toggle()
            }

            HStack
            {
                DismissSheetButton(isShowingSheet: $isShowingSheet)

                Spacer()

                if enableDiscoverability
                {
                    Button
                    {
                        print("Would install package \(foundPackageSelection)")
                        
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
                            
                            installationProgressTracker.packagesBeingInstalled.append(PackageInProgressOfBeingInstalled(package: packageToInstall, installationStage: .ready, packageInstallationProgress: 0))
                            
                            print("Packages to install: \(installationProgressTracker.packagesBeingInstalled)")
                            
                            installationProgressTracker.packageBeingCurrentlyInstalled = packageToInstall.name
                            
                            packageInstallationProcessStep = .installing
                        }
                        catch let topPackageInstallationError
                        {
                            print("Failet while trying to get top package to install: \(topPackageInstallationError)")
                            
                            dismiss()
                            
                            appState.fatalAlertType = .topPackageArrayFilterCouldNotRetrieveAnyPackages
                            appState.isShowingFatalError = true
                            
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
