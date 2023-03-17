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
    @StateObject var outdatedPackageTracker = OutdatedPackageTracker()

    @StateObject var selectedPackageInfo = SelectedPackageInfo()
    @StateObject var selectedTapInfo = SelectedTapInfo()

    var body: some Scene
    {
        WindowGroup
        {
            ContentView()
                .environmentObject(appState)
                .environmentObject(brewData)
                .environmentObject(availableTaps)
                .environmentObject(selectedPackageInfo)
                .environmentObject(selectedTapInfo)
                .environmentObject(updateProgressTracker)
                .environmentObject(outdatedPackageTracker)
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

            SidebarCommands()
            CommandGroup(replacing: .newItem) // Disables "New Window"
            {
                
            }

            CommandMenu("Packages")
            {
                Button
                {
                    appState.isShowingInstallationSheet.toggle()
                } label: {
                    Text("Install Packages…")
                }
                .keyboardShortcut("n")

                Button
                {
                    appState.isShowingAddTapSheet.toggle()
                } label: {
                    Text("Add a Tap…")
                }
                .keyboardShortcut("n", modifiers: [.command, .option])

                Divider()

                Button
                {
                    appState.isShowingUpdateSheet = true
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
                    Text("Perform Maintenance…")
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
