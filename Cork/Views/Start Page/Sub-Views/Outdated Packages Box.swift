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
    enum OutdatedPackageDisplayStage
    {
        case checkingForUpdates, showingOutdatedPackages, noUpdatesAvailable, erroredOut(reason: String)
    }

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker

    @Binding var isOutdatedPackageDropdownExpanded: Bool

    let errorOutReason: String?

    var outdatedPackageDisplayStage: OutdatedPackageDisplayStage
    {
        if let errorOutReason
        {
            return .erroredOut(reason: errorOutReason)
        }
        else
        {
            if appState.isCheckingForPackageUpdates
            {
                return .checkingForUpdates
            }
            else if outdatedPackageTracker.displayableOutdatedPackages.isEmpty
            {
                return .noUpdatesAvailable
            }
            else
            {
                return .showingOutdatedPackages
            }
        }
    }

    var body: some View
    {
        switch outdatedPackageDisplayStage
        {
        case .checkingForUpdates:
            OutdatedPackageLoaderBox()
        case .showingOutdatedPackages:
            OutdatedPackageListBox(isDropdownExpanded: $isOutdatedPackageDropdownExpanded)
        case .noUpdatesAvailable:
            NoUpdatesAvailableBox()
        case .erroredOut(let reason):
            LoadingOfOutdatedPackagesFailedListBox(errorOutReason: reason)
        }
    }
}
