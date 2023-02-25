//
//  CorkApp.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI

@main
struct CorkApp: App
{
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject var appState = AppState()
    @StateObject var brewData = BrewDataStorage()
    @StateObject var availableTaps = AvailableTaps()

    @StateObject var updateProgressTracker = UpdateProgressTracker()

    @StateObject var selectedPackageInfo = SelectedPackageInfo()

    var body: some Scene
    {
        WindowGroup
        {
            ContentView()
                .environmentObject(appState)
                .environmentObject(brewData)
                .environmentObject(availableTaps)
                .environmentObject(selectedPackageInfo)
                .onAppear
                {
                    NSWindow.allowsAutomaticWindowTabbing = false
                }
        }
        .commands
        {
            CommandGroup(replacing: CommandGroupPlacement.appInfo)
            {
                Button
                {
                    appDelegate.showAboutPanel()
                } label: {
                    Text("About \(NSApplication.appName!)")
                }
            }

            CommandGroup(after: .sidebar)
            {
                Button
                {
                    toggleSidebar()
                } label: {
                    Text("Toggle Sidebar")
                }
                .keyboardShortcut("s", modifiers: [.command, .control])
            }

            CommandMenu("Packages")
            {
                Button
                {
                    appState.isShowingInstallationSheet.toggle()
                } label: {
                    Text("Install Packages")
                }
                .keyboardShortcut("n")

                Button
                {
                    appState.isShowingTapATapSheet.toggle()
                } label: {
                    Text("Tap a tap")
                }
                .keyboardShortcut("n", modifiers: [.command, .option])

                Divider()

                Button
                {
                    updateBrewPackages(updateProgressTracker, appState: appState)
                } label: {
                    Text("Update Packages")
                }
                .keyboardShortcut("r")

                /* Divider()

                 Button {
                     print("Will uninstall packages")
                 } label: {
                     Text("Uninstall Package")
                 }
                  */
            }

            CommandMenu("Maintenance")
            {
                Button
                {
                    appState.isShowingMaintenanceSheet.toggle()
                } label: {
                    Text("Perform Brew Maintenance")
                }
                .keyboardShortcut("m")
                
                if appState.cachedDownloadsFolderSize != 0
                {
                    Button {
                        appState.isShowingFastCacheDeletionMaintenanceView.toggle()
                    } label: {
                        Text("Delete Cached Downloads")
                    }
                    .keyboardShortcut("m", modifiers: [.command, .option])
                }

            }
        }
        .windowStyle(.automatic)
        .windowToolbarStyle(.automatic)

        Settings
        {
            SettingsView()
        }
    }
}
