//
//  Menu Bar Item.swift
//  Cork
//
//  Created by David Bureš on 30.03.2024.
//

import SwiftUI

struct MenuBarItem: View
{
    @Environment(\.openWindow) var openWindow
    
    @EnvironmentObject var appState: AppState
    
    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var availableTaps: AvailableTaps
    
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker
    
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
