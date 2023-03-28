//
//  Settings View.swift
//  Cork
//
//  Created by David Bureš on 13.02.2023.
//

import SwiftUI

struct SettingsView: View
{
    var body: some View
    {
        TabView
        {
            GeneralPane()
                .tabItem
                {
                    Label("settings.general", systemImage: "gearshape")
                }

            MaintenancePane()
                .tabItem
                {
                    Label("settings.maintenance", systemImage: "arrow.3.trianglepath")
                }

            BrewPane()
                .tabItem {
                    Label("settings.homebrew", systemImage: "mug")
                }
            /*InstallationAndUninstallationPane()
                .tabItem
                {
                    Label("settings.install-uninstall", systemImage: "plus")
                }*/
        }
    }
}
