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
    @EnvironmentObject var selectedPackageInfo: SelectedPackageInfo
    
    @Binding var currentTokens: [PackageSearchToken]
    @Binding var searchText: String
    
    var body: some View {
        Section("sidebar.section.installed-formulae")
        {
            if !appState.isLoadingFormulae
            {
                
                if currentTokens.contains(where: { $0.tokenSearchResultType == .intentionallyInstalledPackage })
                {
                    ForEach(searchText.isEmpty ? brewData.installedFormulae.filter({ $0.installedIntentionally == true }) : brewData.installedFormulae.filter({ $0.installedIntentionally == true && $0.name.contains(searchText)}))
                    { formula in
                        NavigationLink(tag: formula.id, selection: $appState.navigationSelection)
                        {
                            PackageDetailView(package: formula, packageInfo: selectedPackageInfo)
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
                                    try await uninstallSelectedPackage(package: formula, brewData: brewData, appState: appState, shouldRemoveAllAssociatedFiles: false, shouldApplyUninstallSpinnerToRelevantItemInSidebar: true)
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
                                        try await uninstallSelectedPackage(package: formula, brewData: brewData, appState: appState, shouldRemoveAllAssociatedFiles: true, shouldApplyUninstallSpinnerToRelevantItemInSidebar: true)
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
                    ForEach(searchText.isEmpty || searchText.contains("#") ? brewData.installedFormulae : brewData.installedFormulae.filter { $0.name.contains(searchText) })
                    { formula in
                        NavigationLink(tag: formula.id, selection: $appState.navigationSelection)
                        {
                            PackageDetailView(package: formula, packageInfo: selectedPackageInfo)
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
                                    try await uninstallSelectedPackage(package: formula, brewData: brewData, appState: appState, shouldRemoveAllAssociatedFiles: false, shouldApplyUninstallSpinnerToRelevantItemInSidebar: true)
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
                                        try await uninstallSelectedPackage(package: formula, brewData: brewData, appState: appState, shouldRemoveAllAssociatedFiles: true, shouldApplyUninstallSpinnerToRelevantItemInSidebar: true)
                                    }
                                } label: {
                                    Text("sidebar.section.installed-formulae.contextmenu.uninstall-deep-\(formula.name)")
                                }
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
}
