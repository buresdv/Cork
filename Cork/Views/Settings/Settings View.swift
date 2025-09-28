//
//  Settings View.swift
//  Cork
//
//  Created by David Bureš on 13.02.2023.
//

import SwiftUI
import CorkShared
import Defaults

@Observable
class SettingsState
{
    enum AlertType
    {
        case deepUninstall, cleanupDisabling, customHomebrewLocationNotAnExecutableAtAll, customHomebrewLocationNotABrewExecutable(executablePath: String)
    }

    var alertType: AlertType = .cleanupDisabling
    var isShowingAlert: Bool = false
}

struct SettingsView: View
{
    @Default(.allowMoreCompleteUninstallations) var allowMoreCompleteUninstallations: Bool
    @Default(.isAutomaticCleanupEnabled) var isAutomaticCleanupEnabled: Bool

    @State var settingsState: SettingsState = .init()

    var body: some View
    {
        Group
        {
            if #available(macOS 26.0, *)
            {
                NewSettingsTabs()
            }
            else
            {
                LegacySettingsTabs()
            }
        }
        .environment(settingsState)
        .alert(isPresented: $settingsState.isShowingAlert)
        {
            switch settingsState.alertType
            {
            case .deepUninstall:
                return Alert(
                    title: Text("settings.install-uninstall.uninstallation.allow-more-complete-uninstallation.alert.title"),
                    message: Text("settings.install-uninstall.uninstallation.allow-more-complete-uninstallation.alert.body"),
                    primaryButton: .default(Text("settings.install-uninstall.uninstallation.allow-more-complete-uninstallation.alert.confirm"), action: {
                        allowMoreCompleteUninstallations = true
                        settingsState.isShowingAlert = false
                    }),
                    secondaryButton: .cancel
                    {
                        allowMoreCompleteUninstallations = false
                        settingsState.isShowingAlert = false
                    }
                )
            case .cleanupDisabling:
                return Alert(
                    title: Text("settings.install-uninstall.installation.enable-automatic-cleanup.alert.title"),
                    message: Text("settings.install-uninstall.installation.enable-automatic-cleanup.alert.message"),
                    primaryButton: .destructive(Text("settings.install-uninstall.installation.enable-automatic-cleanup.alert.confirm"), action: {
                        isAutomaticCleanupEnabled = false
                        settingsState.isShowingAlert = false
                    }),
                    secondaryButton: .cancel
                    {
                        isAutomaticCleanupEnabled = true
                        settingsState.isShowingAlert = false
                    }
                )
            case .customHomebrewLocationNotAnExecutableAtAll:
                return Alert(title: Text("settings.brew.custom-homebrew-path.error.not-an-executable-at-all"))
            case .customHomebrewLocationNotABrewExecutable(let executablePath):
                return Alert(title: Text("settings.brew.custom-homebrew-path.error.not-a-brew-executable-\(executablePath)"))
            }
        }
    }
}

@available(macOS 26.0, *)
private struct NewSettingsTabs: View
{
    enum SettingsTabs: @MainActor Identifiable, Hashable, CaseIterable, View
    {
        struct TabIdentifier
        {
            let name: LocalizedStringKey
            let systemImage: String
        }
        
        case generalPane
        case maintenancePane
        case notificationsPane
        case discoverabilityPane
        case installationAndUninstallationPane
        case brewPane
        
        var id: Self { self }
        
        var tabIdentifier: TabIdentifier
        {
            switch self {
            case .generalPane:
                return .init(name: "settings.general", systemImage: "gearshape")
            case .maintenancePane:
                return .init(name: "settings.maintenance", systemImage: "arrow.3.trianglepath")
            case .notificationsPane:
                return .init(name: "settings.notifications", systemImage: "bell.badge")
            case .discoverabilityPane:
                return .init(name: "settings.discoverability", systemImage: "magnifyingglass")
            case .installationAndUninstallationPane:
                return .init(name: "settings.install-uninstall", systemImage: "shippingbox")
            case .brewPane:
                return .init(name: "settings.homebrew", systemImage: "mug")
            }
        }
        
        var body: some View
        {
            switch self {
            case .generalPane:
                GeneralPane()
            case .maintenancePane:
                MaintenancePane()
            case .notificationsPane:
                NotificationsPane()
            case .discoverabilityPane:
                DiscoverabilityPane()
            case .installationAndUninstallationPane:
                InstallationAndUninstallationPane()
            case .brewPane:
                BrewPane()
            }
        }
    }
    
    @State var selectedTab: SettingsTabs = .generalPane
    
    var body: some View
    {
        TabView(selection: $selectedTab.animation())
        {
            ForEach(SettingsTabs.allCases)
            { settingsPane in
                
                Tab(settingsPane.tabIdentifier.name, systemImage: settingsPane.tabIdentifier.systemImage, value: settingsPane)
                {
                    settingsPane.body
                }
            }
        }
        .windowResizeAnchor(.top)
    }
}

private struct LegacySettingsTabs: View
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

            NotificationsPane()
                .tabItem
                {
                    Label("settings.notifications", systemImage: "bell.badge")
                }

            DiscoverabilityPane()
                .tabItem
                {
                    Label("settings.discoverability", systemImage: "magnifyingglass")
                }

            InstallationAndUninstallationPane()
                .tabItem
                {
                    Label("settings.install-uninstall", systemImage: "shippingbox")
                }

            BrewPane()
                .tabItem
                {
                    Label("settings.homebrew", systemImage: "mug")
                }

            /*
             AdvancedPane()
                 .tabItem {
                     Label("settings.advanced", systemImage: "gearshape.2")
                 }
              */
        }
    }
}
