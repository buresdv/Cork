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
    
    @Binding var isUninstallingOrphanedPackages: Bool
    @Binding var isPurgingHomebrewCache: Bool
    @Binding var isDeletingCachedDownloads: Bool
    
    var body: some View
    {
        MenuBar_PackageOverview()

        Divider()

        MenuBar_PackageUpdating()

        Divider()
        
        MenuBar_PackageInstallation()

        Divider()

        MenuBar_OrphanCleanup(isUninstallingOrphanedPackages: $isUninstallingOrphanedPackages)
        MenuBar_CacheCleanup(isPurgingHomebrewCache: $isPurgingHomebrewCache)
        MenuBar_CachedDownloadsCleanup(isDeletingCachedDownloads: $isDeletingCachedDownloads)

        Divider()

        OpenCorkButton()

        Divider()

        QuitCorkButton()
    }
}
