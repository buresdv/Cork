//
//  Formulae Section.swift
//  Cork
//
//  Created by David Bureš on 03.06.2023.
//

import SwiftUI

struct FormulaeSection: View {
    
    @AppStorage("allowMoreCompleteUninstallations") var allowMoreCompleteUninstallations: Bool = false
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker
    
    @Binding var currentTokens: [PackageSearchToken]
    @Binding var searchText: String
    
    var body: some View {
        Section("sidebar.section.installed-formulae")
        {
            if !appState.isLoadingFormulae
            {
                ForEach(displayedFormulae)
                { formula in
                    NavigationLink(tag: formula.id, selection: $appState.navigationSelection)
                    {
                        PackageDetailView(package: formula)
                    } label: {
                        PackageListItem(packageItem: formula)
                    }
                    .contextMenu
                    {
                        if !formula.isTagged
                        {
                            Button
                            {
                                Task
                                {
                                    await tagPackage(package: formula, brewData: brewData, appState: appState)
                                }
                            } label: {
                                Text("sidebar.section.all.contextmenu.tag-\(formula.name)")
                            }
                        }
                        else
                        {
                            Button
                            {
                                Task
                                {
                                    await untagPackage(package: formula, brewData: brewData, appState: appState)
                                }
                            } label: {
                                Text("sidebar.section.all.contextmenu.untag-\(formula.name)")
                            }
                        }

                        Divider()

                        Button
                        {
                            Task
                            {
                                try await uninstallSelectedPackage(
                                    package: formula,
                                    brewData: brewData,
                                    appState: appState,
                                    outdatedPackageTracker: outdatedPackageTracker,
                                    shouldRemoveAllAssociatedFiles: false,
                                    shouldApplyUninstallSpinnerToRelevantItemInSidebar: true
                                )
                            }
                        } label: {
                            Text("sidebar.section.installed-formulae.contextmenu.uninstall-\(formula.name)")
                        }

                        if allowMoreCompleteUninstallations
                        {
                            Button
                            {
                                Task
                                {
                                    try await uninstallSelectedPackage(
                                        package: formula,
                                        brewData: brewData,
                                        appState: appState,
                                        outdatedPackageTracker: outdatedPackageTracker,
                                        shouldRemoveAllAssociatedFiles: true,
                                        shouldApplyUninstallSpinnerToRelevantItemInSidebar: true
                                    )
                                }
                            } label: {
                                Text("sidebar.section.installed-formulae.contextmenu.uninstall-deep-\(formula.name)")
                            }
                        }

                    }
                }
            }
            else
            {
                ProgressView()
            }
        }
        .collapsible(true)
    }

    private var displayedFormulae: [BrewPackage]
    {
        guard !appState.isLoadingFormulae else
        {
            return []
        }

        let filter: (BrewPackage) -> Bool

        if currentTokens.contains(.intentionallyInstalledPackage)
        {
            if searchText.isEmpty
            {
                filter = \.installedIntentionally
            } else
            {
                filter = { $0.installedIntentionally && $0.name.contains(searchText)  }
            }
        } 
        else
        {
            if searchText.isEmpty || searchText.contains("#")
            {
                filter = { _ in true }
            } 
            else
            {
                filter = { $0.name.contains(searchText) }
            }
        }

        return brewData.installedFormulae.filter(filter)
    }
}
