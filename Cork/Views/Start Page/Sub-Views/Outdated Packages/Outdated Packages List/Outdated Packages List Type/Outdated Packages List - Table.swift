//
//  Outdated Packages List - Table.swift
//  Cork
//
//  Created by David Bureš - P on 06.01.2026.
//

import SwiftUI
import Defaults
import CorkModels

struct OutdatedPackagesList_Table: View
{
    // TODO: Pretty much all these properties shared with the List version of this. Find a way to merge them
    
    @Environment(OutdatedPackagesTracker.self) var outdatedPackagesTracker: OutdatedPackagesTracker
    
    let packageUpdatingType: OutdatedPackage.PackageUpdatingType
    
    /// Filter out those relevant packages for this context form the tracker
    var relevantPackages: Set<OutdatedPackage>
    {
        switch packageUpdatingType
        {
        case .homebrew:
            return outdatedPackagesTracker.packagesManagedByHomebrew
        case .selfUpdating:
            return outdatedPackagesTracker.packagesThatUpdateThemselves
        }
    }
    
    var sortedRelevantPackages: [OutdatedPackage]
    {
        return relevantPackages.sorted(by: { $0.package.installedOn! < $1.package.installedOn! })
    }
    
    var filteredRelevantPackages: [OutdatedPackage]
    {
        guard !searchText.isEmpty else
        {
            return sortedRelevantPackages
        }
        
        return sortedRelevantPackages.filter({ $0.package.getPackageName(withPrecision: .precise).localizedCaseInsensitiveContains(searchText) })
    }
    
    /// Check whether all relevant packages are deselected - for `Deselect All` button
    var areAnyRelevantPackagesSelected: Bool
    {
        !relevantPackages.filter({ $0.isSelected }).isEmpty
    }
    
    /// Check if there is at least one package that is not selected - for `Select All` button
    var areAnyPackagesLeftToSelect: Bool
    {
        return relevantPackages.filter({ !$0.isSelected }).isEmpty
    }
    
    @State private var isShowingSearchField: Bool = false
    
    @State private var searchText: String = ""
    
    var body: some View
    {
        GroupBox
        {
            VStack(spacing: 0)
            {
                VStack(spacing: 2)
                {
                    HStack(alignment: .center)
                    {
                        selectAllButton(packagesToSelect: relevantPackages)
                        
                        deselectAllButton(packagesToDeselect: relevantPackages)
                        
                        Spacer()
                        
                        ToggleSearchFieldButton(isShowingSearchField: $isShowingSearchField)
                    }
                    
                    if isShowingSearchField
                    {
                        VStack(spacing: 2)
                        {
                            Divider()
                            
                            CustomSearchField(search: $searchText, customPromptText: nil)
                                .animation(.smooth, value: isShowingSearchField)
                        }
                    }
                }
                .padding([.horizontal, .top], 4)
            }
            
            Table(of: OutdatedPackage.self)
            {
                TableColumn("start-page.updates.action")
                { outdatedPackage in
                    Toggle(isOn: Bindable(outdatedPackage).isSelected) {
                        EmptyView()
                    }
                }
                .width(45)

                TableColumn("package-details.dependencies.results.name")
                { outdatedPackage in
                    Text(outdatedPackage.package.getPackageName(withPrecision: .precise))
                }
        

                TableColumn("start-page.updates.installed-version")
                { outdatedPackage in
                    Text(outdatedPackage.installedVersions.formatted(.list(type: .and)))
                }

                TableColumn("start-page.updates.newest-version")
                { outdatedPackage in
                    Text(outdatedPackage.newerVersion)
                }

                TableColumn("package-details.type")
                { outdatedPackage in
                    Text(outdatedPackage.package.type.description)
                }

            } rows: {
                ForEach(filteredRelevantPackages)
                { outdatedPackage in
                    TableRow(outdatedPackage)
                        .contextMenu
                        {
                            PreviewPackageButton(packageToPreview: .init(
                                name: outdatedPackage.package.getPackageName(withPrecision: .precise),
                                type: outdatedPackage.package.type,
                                installedIntentionally: outdatedPackage.package.installedIntentionally)
                            )
                        }
                }
            }
            .tableStyle(.bordered)
        }
    }
    
    @ViewBuilder
    func selectAllButton(packagesToSelect: Set<OutdatedPackage>) -> some View
    {
        Button
        {
            relevantPackages.forEach
            {
                $0.changeSelectedState(to: true)
            }
        } label: {
            Text("start-page.updated.action.select-all")
        }
        .disabled(areAnyPackagesLeftToSelect)
        .buttonStyle(.accessoryBar)
    }
    
    @ViewBuilder
    func deselectAllButton(packagesToDeselect: Set<OutdatedPackage>) -> some View
    {
        Button
        {
            relevantPackages.forEach
            {
                $0.changeSelectedState(to: false)
            }
        } label: {
            Text("start-page.updated.action.deselect-all")
        }
        .disabled(!areAnyRelevantPackagesSelected)
        .buttonStyle(.accessoryBar)
    }
}
