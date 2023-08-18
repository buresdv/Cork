//
//  Casks Section.swift
//  Cork
//
//  Created by David Bureš on 03.06.2023.
//

import SwiftUI

struct CasksSection: View {
    
    @AppStorage("allowMoreCompleteUninstallations") var allowMoreCompleteUninstallations: Bool = false
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var selectedPackageInfo: SelectedPackageInfo
    
    @Binding var searchText: String
    
    var body: some View {
        Section("sidebar.section.installed-casks")
        {
            if !appState.isLoadingCasks
            {
                ForEach(searchText.isEmpty || searchText.contains("#") ? brewData.installedCasks : brewData.installedCasks.filter { $0.name.contains(searchText) })
                { cask in
                    NavigationLink(tag: cask.id, selection: $appState.navigationSelection)
                    {
                        PackageDetailView(package: cask, packageInfo: selectedPackageInfo)
                    } label: {
                        PackageListItem(packageItem: cask)
                    }
                    .contextMenu
                    {
                        if cask.isTagged
                        {
                            Button
                            {
                                Task
                                {
                                    await untagPackage(package: cask, brewData: brewData, appState: appState)
                                }
                            } label: {
                                Text("sidebar.section.all.contextmenu.untag-\(cask.name)")
                            }
                        }
                        else
                        {
                            Button
                            {
                                Task
                                {
                                    await tagPackage(package: cask, brewData: brewData, appState: appState)
                                }
                            } label: {
                                Text("sidebar.section.all.contextmenu.tag-\(cask.name)")
                            }
                        }
                        
                        Divider()
                        
                        Button
                        {
                            Task
                            {
                                try await uninstallSelectedPackage(package: cask, brewData: brewData, appState: appState, shouldRemoveAllAssociatedFiles: false)
                            }
                        } label: {
                            Text("sidebar.section.installed-casks.contextmenu.uninstall-\(cask.name)")
                        }
                        
                        if allowMoreCompleteUninstallations
                        {
                            Button
                            {
                                Task
                                {
                                    try await uninstallSelectedPackage(package: cask, brewData: brewData, appState: appState, shouldRemoveAllAssociatedFiles: true)
                                }
                            } label: {
                                Text("sidebar.section.installed-formulae.contextmenu.uninstall-deep-\(cask.name)")
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
