//
//  Outdated Packages List.swift
//  Cork
//
//  Created by David Bureš - P on 06.01.2026.
//

import CorkModels
import Defaults
import SwiftUI

/// Encapsulates both the managed and unmanaged lists
struct OutdatedPackagesList: View
{
    @Default(.outdatedPackageInfoDisplayAmount) var outdatedPackageInfoDisplayAmount

    @Environment(OutdatedPackagesTracker.self) var outdatedPackagesTracker: OutdatedPackagesTracker

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
                DisclosureGroup("start-page.updates.self-updating.\(numberOfSelfManagedUpdates).list")
                {
                    OutdatedPackagesList_List(packageUpdatingType: .selfUpdating)
                }
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
                DisclosureGroup("start-page.updates.self-updating.\(numberOfSelfManagedUpdates).list")
                {
                    OutdatedPackagesList_Table(packageUpdatingType: .selfUpdating)
                }
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
