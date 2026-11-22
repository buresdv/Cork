//
//  Outdated Packages List.swift
//  Cork
//
//  Created by David Bureš - P on 06.01.2026.
//

import CorkModels
import Defaults
import SwiftUI
import FactoryKit

/// Encapsulates both the managed and unmanaged lists
struct OutdatedPackagesList: View
{
    @Default(.outdatedPackageInfoDisplayAmount) var outdatedPackageInfoDisplayAmount

    @InjectedObservable(\.outdatedPackagesTracker) var outdatedPackagesTracker: OutdatedPackagesTracker
    
    @Default(.automaticallyExpandOutdatedPackageList) var automaticallyExpandOutdatedPackageList: Bool
    
    @State private var isManagedUpdatesDropdownExpanded: Bool = false
    @State private var isUnmanagedUpdatesDropdownExpanded: Bool = false

    var areThereAnyHomebrewManagedUpdatesAvailable: Bool
    {
        return !outdatedPackagesTracker.packagesManagedByHomebrew.isEmpty
    }
    
    var areThereAnySelfManagedUpdatesAvailable: Bool
    {
        return !outdatedPackagesTracker.packagesThatUpdateThemselves.isEmpty
    }
    
    var numberOfSelfManagedUpdates: Int
    {
        return outdatedPackagesTracker.packagesThatUpdateThemselves.count
    }
    
    var body: some View
    {
        Group
        {
            DisclosureGroup(isExpanded: $isManagedUpdatesDropdownExpanded)
            {
                switch outdatedPackageInfoDisplayAmount
                {
                case .none, .versionOnly:
                    
                    if areThereAnyHomebrewManagedUpdatesAvailable
                    {
                        OutdatedPackagesList_List(packageUpdatingType: .homebrew)
                    }
                    else
                    {
                        noManagedUpdatesAvailableMessage
                    }
                    
                    if areThereAnySelfManagedUpdatesAvailable
                    {
                        DisclosureGroup(isExpanded: $isUnmanagedUpdatesDropdownExpanded)
                        {
                            OutdatedPackagesList_List(packageUpdatingType: .selfUpdating)
                        } label: {
                            Text("start-page.updates.unmanaged-only.list")
                        }
                        .betterDisclosureGroupStyle()
                    }
                case .all:
                    
                    if areThereAnyHomebrewManagedUpdatesAvailable
                    {
                        OutdatedPackagesList_Table(packageUpdatingType: .homebrew)
                    }
                    else
                    {
                        noManagedUpdatesAvailableMessage
                    }
                    
                    if areThereAnySelfManagedUpdatesAvailable
                    {
                        DisclosureGroup(isExpanded: $isUnmanagedUpdatesDropdownExpanded)
                        {
                            OutdatedPackagesList_Table(packageUpdatingType: .selfUpdating)
                        } label: {
                            Text("start-page.updates.unmanaged-only.list")
                        }
                        .betterDisclosureGroupStyle()
                    }
                }
            } label: {
                Text("start-page.updates.list")
            }
        }
        .onAppear
        {
            if automaticallyExpandOutdatedPackageList
            {
                isManagedUpdatesDropdownExpanded = true
                isUnmanagedUpdatesDropdownExpanded = true
            }
        }
    }
    
    @ViewBuilder
    var noManagedUpdatesAvailableMessage: some View
    {
        Text("update-packages.no-managed-updates")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .padding([.leading])
    }
}
