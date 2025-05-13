//
//  Outdated Packages.swift
//  Cork
//
//  Created by David Bureš on 06.10.2023.
//

import SwiftUI

struct OutdatedPackagesBox: View
{
    /// The type of outdated package box that will show up
    enum OutdatedPackageDisplayStage: Equatable
    {
        case checkingForUpdates, showingOutdatedPackages, noUpdatesAvailable, erroredOut(reason: String)
    }

    @Environment(AppState.self) var appState: AppState
    @Environment(OutdatedPackagesTracker.self) var outdatedPackagesTracker: OutdatedPackagesTracker

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
