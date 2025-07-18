//
//  Outdated Packages.swift
//  Cork
//
//  Created by David Bureš on 06.10.2023.
//

import SwiftUI

struct OutdatedPackagesBox: View
{
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker

    @Binding var isOutdatedPackageDropdownExpanded: Bool

    var body: some View
    {
        Group
        {
            switch outdatedPackageTracker.outdatedPackageDisplayStage
            {
            case .checkingForUpdates:
                OutdatedPackageLoaderBox(errorOutReason: $outdatedPackageTracker.errorOutReason)
            case .showingOutdatedPackages:
                OutdatedPackageListBox(isDropdownExpanded: $isOutdatedPackageDropdownExpanded)
            case .noUpdatesAvailable:
                NoUpdatesAvailableBox()
            case .erroredOut(let reason):
                LoadingOfOutdatedPackagesFailedListBox(errorOutReason: reason)
            }
        }
        .animation(.snappy, value: outdatedPackageTracker.outdatedPackageDisplayStage)
    }
}
