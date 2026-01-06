//
//  Outdated Packages List.swift
//  Cork
//
//  Created by David Bureš - P on 06.01.2026.
//

import SwiftUI
import CorkModels
import Defaults

struct OutdatedPackagesList: View
{
    @Default(.outdatedPackageInfoDisplayAmount) var outdatedPackageInfoDisplayAmount
    
    @Environment(OutdatedPackagesTracker.self) var outdatedPackagesTracker: OutdatedPackagesTracker
    
    var body: some View
    {        
        if outdatedPackagesTracker.displayableOutdatedPackagesTracker.packagesManagedByHomebrew.isEmpty
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
            case .all:
                OutdatedPackagesList_Table()
            }
        }
    }
}
