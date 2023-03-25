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
                .environmentObject(appDelegate.appState)
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
                    Text("navigation.about")
                }
            }

            SidebarCommands()
            CommandGroup(replacing: .newItem) // Disables "New Window"
            {
                
            }

            CommandMenu("navigation.menu.packages")
            {
                Button
                {
                    appDelegate.appState.isShowingInstallationSheet.toggle()
                } label: {
                    Text("navigation.menu.packages.install")
                }
                .keyboardShortcut("n")

                Button
                {
                    appDelegate.appState.isShowingAddTapSheet.toggle()
                } label: {
                    Text("navigation.menu.packages.add-tap")
                }
                .keyboardShortcut("n", modifiers: [.command, .option])

                Divider()

                Button
                {
                    appDelegate.appState.isShowingUpdateSheet = true
                } label: {
                    Text("navigation.menu.packages.update")
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

            CommandMenu("navigation.menu.maintenance")
            {
                Button
                {
                    appDelegate.appState.isShowingMaintenanceSheet.toggle()
                } label: {
                    Text("navigation.menu.maintenance.perform")
                }
                .keyboardShortcut("m")
                
                if appDelegate.appState.cachedDownloadsFolderSize != 0
                {
                    Button {
                        appDelegate.appState.isShowingFastCacheDeletionMaintenanceView.toggle()
                    } label: {
                        Text("navigation.menu.maintenance.delete-cached-downloads")
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
