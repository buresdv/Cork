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
            case .all:
                OutdatedPackagesList_Table(packageUpdatingType: .homebrew)
            }
        }
    }
}
