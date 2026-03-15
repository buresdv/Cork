//
//  Menu Bar Item.swift
//  Cork
//
//  Created by David Bureš on 30.03.2024.
//

import SwiftUI
import CorkModels
import FactoryKit

struct MenuBarItem: View
{
    @Environment(\.openWindow) var openWindow: OpenWindowAction

    @InjectedObservable(\.appState) var appState: AppState

    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker
    @Environment(TapTracker.self) var tapTracker: TapTracker

    @Environment(OutdatedPackagesTracker.self) var outdatedPackagesTracker: OutdatedPackagesTracker

    var body: some View
    {
        MenuBar_PackageOverview()

        Divider()

        MenuBar_PackageUpdating()

        Divider()

        MenuBar_PackageInstallation()

        Divider()

        MenuBar_OrphanCleanup()
        MenuBar_CacheCleanup()
        MenuBar_CachedDownloadsCleanup()

        Divider()

        OpenCorkButton()

        Divider()

        QuitCorkButton()
    }
}
