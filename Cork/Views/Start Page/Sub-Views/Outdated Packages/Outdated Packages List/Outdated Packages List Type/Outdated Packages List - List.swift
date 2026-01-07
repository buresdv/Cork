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
    
    /// Check whether all relevant packages are deselected
    var areAnyRelevantPackagesSelected: Bool
    {
        !relevantPackages.filter({ $0.isMarkedForUpdating }).isEmpty
    }
    
    var body: some View
    {
        List
        {
            Section
            {
                ForEach(relevantPackages.sorted(by: { $0.package.installedOn! < $1.package.installedOn! }))
                { outdatedPackage in
                    Toggle(isOn: Bindable(outdatedPackage).isMarkedForUpdating)
                    {
                        OutdatedPackageListBoxRow(outdatedPackage: outdatedPackage)
                    }
                }
            } header: {
                // TODO: Implement this
                 HStack(alignment: .center, spacing: 10)
                 {
                     deselectAllButton(packagesToDeselect: relevantPackages)

                     selectAllButton(packagesToSelect: relevantPackages)
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
        .disabled(outdatedPackagesTracker.packagesMarkedForUpdating.isEmpty)
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
