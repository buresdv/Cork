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
                .onAppear {
                    NSWindow.allowsAutomaticWindowTabbing = false
                }
        }
        .commands(content: {
            CommandGroup(replacing: CommandGroupPlacement.appInfo)
            {
                Button
                {
                    appDelegate.showAboutPanel()
                } label: {
                    Text("About \(NSApplication.appName!)")
                }
            }
            
            CommandGroup(after: .sidebar) {
                Button
                {
                    toggleSidebar()
                } label: {
                    Text("Toggle Sidebar")
                }
                .keyboardShortcut("s", modifiers: [.command, .control])
            }
        })
        .windowStyle(.automatic)
        .windowToolbarStyle(.automatic)
        
        Settings {
            SettingsView()
        }
    }
}
