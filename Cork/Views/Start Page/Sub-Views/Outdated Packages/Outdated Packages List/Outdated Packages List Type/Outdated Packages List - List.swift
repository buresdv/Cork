//
//  Outdated Packages List - List.swift
//  Cork
//
//  Created by David Bureš - P on 06.01.2026.
//

import CorkModels
import Defaults
import SwiftUI

struct OutdatedPackagesList_List: View
{
    @Default(.outdatedPackageInfoDisplayAmount) var outdatedPackageInfoDisplayAmount
    
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
        
        return sortedRelevantPackages.filter({ $0.package.name.localizedCaseInsensitiveContains(searchText) })
    }
    
    /// Check whether all relevant packages are deselected - for `Deselect All` button
    var areAnyRelevantPackagesSelected: Bool
    {
        !relevantPackages.filter({ $0.isMarkedForUpdating }).isEmpty
    }
    
    /// Check if there is at least one package that is not selected - for `Select All` button
    var areAnyPackagesLeftToSelect: Bool
    {
        return relevantPackages.filter({ !$0.isMarkedForUpdating }).isEmpty
    }
    
    @State private var isShowingSearchField: Bool = false
    
    @State private var searchText: String = ""
    
    var body: some View
    {
        List
        {
            Section
            {
                ForEach(filteredRelevantPackages)
                { outdatedPackage in
                    Toggle(isOn: Bindable(outdatedPackage).isMarkedForUpdating)
                    {
                        OutdatedPackageListBoxRow(outdatedPackage: outdatedPackage)
                    }
                }
            } header: {
                VStack(alignment: .leading, spacing: 5)
                {
                    HStack(alignment: .center, spacing: 10)
                    {
                        deselectAllButton(packagesToDeselect: relevantPackages)

                        selectAllButton(packagesToSelect: relevantPackages)
                        
                        Spacer()
                        
                        ToggleSearchFieldButton(isShowingSearchField: $isShowingSearchField)
                    }
                   
                   if isShowingSearchField
                   {
                       Divider()
                       
                       CustomSearchField(
                           search: $searchText,
                           customPromptText: nil
                       )
                       .transition(.push(from: .top))
                   }
                }
            }
        }
        .listStyle(.bordered(alternatesRowBackgrounds: true))
    }
    
    @ViewBuilder
    func selectAllButton(packagesToSelect: Set<OutdatedPackage>) -> some View
    {
        Button
        {
            relevantPackages.forEach
            {
                $0.changeMarkedState(to: true)
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
                $0.changeMarkedState(to: false)
            }
        } label: {
            Text("start-page.updated.action.deselect-all")
        }
        .disabled(!areAnyRelevantPackagesSelected)
        .buttonStyle(.accessoryBar)
    }
}
