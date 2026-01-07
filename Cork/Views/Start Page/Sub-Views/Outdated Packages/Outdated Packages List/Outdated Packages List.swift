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
        if outdatedPackagesTracker.packagesManagedByHomebrew.isEmpty
        {
            Text("update-packages.no-managed-updates")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        else
        {
            switch outdatedPackageInfoDisplayAmount
            {
            case .none, .versionOnly:
                OutdatedPackagesList_List(packageUpdatingType: .homebrew)
                
                if areThereAnySelfManagedUpdatesAvailable
                {
                    DisclosureGroup("start-page.updates.self-updating.\(numberOfSelfManagedUpdates).list")
                    {
                        OutdatedPackagesList_List(packageUpdatingType: .selfUpdating)
                    }
                }
            case .all:
                OutdatedPackagesList_Table(packageUpdatingType: .homebrew)
                
                if areThereAnySelfManagedUpdatesAvailable
                {
                    DisclosureGroup("start-page.updates.self-updating.\(numberOfSelfManagedUpdates).list")
                    {
                        OutdatedPackagesList_Table(packageUpdatingType: .selfUpdating)
                    }
                }
            }
        }
    }
}
