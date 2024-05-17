//
//  Installation Pane.swift
//  Cork
//
//  Created by David Bureš on 13.02.2023.
//

import SwiftUI

struct InstallationAndUninstallationPane: View
{
    @AppStorage("shouldRequestPackageRemovalConfirmation") var shouldRequestPackageRemovalConfirmation: Bool = false

    @AppStorage("showCompatibilityWarning") var showCompatibilityWarning: Bool = true

    @AppStorage("showPackagesStillLeftToInstall") var showPackagesStillLeftToInstall: Bool = false

    @AppStorage("purgeCacheAfterEveryUninstallation") var purgeCacheAfterEveryUninstallation: Bool = false
    @AppStorage("removeOrphansAfterEveryUninstallation") var removeOrphansAfterEveryUninstallation: Bool = false

    @AppStorage("showRealTimeTerminalOutputOfOperations") var showRealTimeTerminalOutputOfOperations: Bool = false
    @AppStorage("openRealTimeTerminalOutputByDefault") var openRealTimeTerminalOutputByDefault: Bool = false

    @AppStorage("allowMoreCompleteUninstallations") var allowMoreCompleteUninstallations: Bool = false

    @AppStorage("isAutomaticCleanupEnabled") var isAutomaticCleanupEnabled = true
    
    @AppStorage("allowAdvancedHomebrewSettings") var allowAdvancedHomebrewSettings: Bool = false

    @EnvironmentObject var settingsState: SettingsState

    var body: some View
    {
        SettingsPaneTemplate
        {
            Form
            {
                /*
                 LabeledContent
                 {
                 Toggle(isOn: $showPackagesStillLeftToInstall)
                 {
                 Text("settings.install-uninstall.installation.toggle")
                 }
                 } label: {
                 Text("settings.install-uninstall.installation")
                 }

                 LabeledContent
                 {
                 VStack(alignment: .leading)
                 {
                 Toggle(isOn: $purgeCacheAfterEveryUninstallation)
                 {
                 Text("settings.install-uninstall.uninstallation.purge-cache")
                 }
                 Toggle(isOn: $removeOrphansAfterEveryUninstallation)
                 {
                 Text("settings.install-uninstall.uninstallation.remove-orphans")
                 }
                 }
                 } label: {
                 Text("settings.install-uninstall.uninstallation")
                 }
                 */

                LabeledContent
                {
                    Toggle(isOn: $shouldRequestPackageRemovalConfirmation)
                    {
                        Text("settings.install-uninstall.request-removal-confirmation.toggle")
                    }
                } label: {
                    Text("settings.install-uninstall.package-removal.label")
                }

                LabeledContent
                {
                    Toggle(isOn: $showCompatibilityWarning)
                    {
                        Text("settings.install-uninstall.compatibility-checking.toggle")
                    }
                } label: {
                    Text("settings.install-uninstall.compatibility-checking.label")
                }

                LabeledContent
                {
                    VStack(alignment: .leading)
                    {
                        VStack(alignment: .leading)
                        {
                            Toggle(isOn: $showRealTimeTerminalOutputOfOperations)
                            {
                                Text("settings.install-uninstall.uninstallation.show-real-time-terminal-outputs")
                            }

                            Toggle(isOn: $openRealTimeTerminalOutputByDefault)
                            {
                                Text("settings.install-uninstall.uninstallation.show-real-time-terminal-outputs.open-by-default")
                            }
                            .disabled(!showRealTimeTerminalOutputOfOperations)
                            .padding(.leading)
                        }

                        VStack(alignment: .leading)
                        {
                            Toggle(isOn: $allowMoreCompleteUninstallations)
                            {
                                Text("settings.install-uninstall.uninstallation.allow-more-complete-uninstallation")
                            }
                            .onChange(of: allowMoreCompleteUninstallations, perform: { newValue in
                                if newValue == true
                                {
                                    settingsState.alertType = .deepUninstall
                                    settingsState.isShowingAlert = true
                                }
                            })

                            HStack(alignment: .top)
                            {
                                Text("􀇾")
                                Text("settings.install-uninstall.uninstallation.allow-more-complete-uninstallation.warning")
                            }
                            .font(.caption)
                            .foregroundColor(Color(nsColor: NSColor.systemGray))
                        }
                        .disabled(!allowAdvancedHomebrewSettings)

                        VStack(alignment: .leading)
                        {
                            Toggle(isOn: $isAutomaticCleanupEnabled)
                            {
                                Text("settings.install-uninstall.installation.enable-automatic-cleanup")
                            }
                            .onChange(of: isAutomaticCleanupEnabled)
                            { newValue in
                                if newValue == false
                                {
                                    settingsState.alertType = .cleanupDisabling
                                    settingsState.isShowingAlert = true
                                }
                            }

                            HStack(alignment: .top)
                            {
                                Text("􀇾")
                                Text("settings.install-uninstall.installation.enable-automatic-cleanup.warning")
                            }
                            .font(.caption)
                            .foregroundColor(Color(nsColor: NSColor.systemGray))
                        }
                        .disabled(!allowAdvancedHomebrewSettings)
                    }
                } label: {
                    Text("settings.dangerous")
                }
            }
        }
    }
}
