//
//  Settings View.swift
//  Cork
//
//  Created by David Bureš on 13.02.2023.
//

import SwiftUI

class SettingsState: ObservableObject
{
    enum AlertType
    {
        case deepUninstall, cleanupDisabling
    }
    
    @Published var alertType: AlertType = .cleanupDisabling
    @Published var isShowingAlert: Bool = false
}

struct SettingsView: View
{
    @AppStorage("allowMoreCompleteUninstallations") var allowMoreCompleteUninstallations: Bool = false
    @AppStorage("isAutomaticCleanupEnabled") var isAutomaticCleanupEnabled = true
    
    @StateObject var settingsState: SettingsState = .init()
    
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

            NotificationsPane()
                .tabItem {
                    Label("settings.notifications", systemImage: "bell.badge")
                }
            
            DiscoverabilityPane()
                .tabItem {
                    Label("settings.discoverability", systemImage: "magnifyingglass")
                }
            
            InstallationAndUninstallationPane()
                .tabItem {
                    Label("settings.install-uninstall", systemImage: "shippingbox")
                }
            
            BrewPane()
                .tabItem {
                    Label("settings.homebrew", systemImage: "mug")
                }
            
            /*
            AdvancedPane()
                .tabItem {
                    Label("settings.advanced", systemImage: "gearshape.2")
                }
             */
        }
        .environmentObject(settingsState)
        .alert(isPresented: $settingsState.isShowingAlert)
        {
            switch settingsState.alertType {
                case .deepUninstall:
                    return Alert(
                        title: Text("settings.install-uninstall.uninstallation.allow-more-complete-uninstallation.alert.title"),
                        message: Text("settings.install-uninstall.uninstallation.allow-more-complete-uninstallation.alert.body"),
                        primaryButton: .default(Text("settings.install-uninstall.uninstallation.allow-more-complete-uninstallation.alert.confirm"), action: {
                            allowMoreCompleteUninstallations = true
                            settingsState.isShowingAlert = false
                        }),
                        secondaryButton: .cancel({
                            allowMoreCompleteUninstallations = false
                            settingsState.isShowingAlert = false
                        }))
                case .cleanupDisabling:
                    return Alert(
                        title: Text("settings.install-uninstall.installation.enable-automatic-cleanup.alert.title"),
                        message: Text("settings.install-uninstall.installation.enable-automatic-cleanup.alert.message"),
                        primaryButton: .destructive(Text("settings.install-uninstall.installation.enable-automatic-cleanup.alert.confirm"), action: {
                            isAutomaticCleanupEnabled = false
                            settingsState.isShowingAlert = false
                        }),
                        secondaryButton: .cancel({
                            isAutomaticCleanupEnabled = true
                            settingsState.isShowingAlert = false
                        })
                    )
            }
        }
    }
}
