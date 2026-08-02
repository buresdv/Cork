//
//  Installation Pane.swift
//  Cork
//
//  Created by David Bureš on 13.02.2023.
//

import SwiftUI
import Defaults
import CorkShared

struct InstallationAndUninstallationPane: View
{
    @Default(.shouldRequestPackageRemovalConfirmation) var shouldRequestPackageRemovalConfirmation: Bool

    @Default(.showInteractiveCapsule) var showInteractiveCapsule: Bool
    
    @Default(.caveatDisplayOptions) var caveatDisplayOptions: PackageCaveatDisplay
    
    @Default(.showCompatibilityWarning) var showCompatibilityWarning: Bool
    @Default(.includeGreedyOutdatedPackages) var includeGreedyOutdatedPackages: Bool

    @Default(.showRealTimeTerminalOutputOfOperations) var showRealTimeTerminalOutputOfOperations: Bool
    @Default(.openRealTimeTerminalOutputByDefault) var openRealTimeTerminalOutputByDefault: Bool

    @Default(.automaticallyAcceptEULA) var automaticallyAcceptEULA: Bool

    @Default(.allowMoreCompleteUninstallations) var allowMoreCompleteUninstallations: Bool

    @Default(.isAutomaticCleanupEnabled) var isAutomaticCleanupEnabled: Bool

    @Default(.allowAdvancedHomebrewSettings) var allowAdvancedHomebrewSettings: Bool

    @Environment(SettingsState.self) var settingsState: SettingsState

    var body: some View
    {
        SettingsPaneTemplate
        {
            Form
            {
            // TODO: Implement this
                /*
                LabeledContent
                {
                    VStack(alignment: .leading)
                    {
                        Defaults.Toggle("settings.packages.highlight-interactive-elements", key: .showInteractiveCapsule)
                        
                        Defaults.Toggle("settings.packages.highlight-interactive-elements.include-package-type", key: .showPackageTypeNextToInteractiveCapsule)
                            .padding(.leading)
                            .disabled(!showInteractiveCapsule)
                    }
                } label: {
                    Text("settings.packages-design.label")
                }

                 */
                
                LabeledContent
                {
                    Defaults.Toggle(key: .shouldRequestPackageRemovalConfirmation)
                    {
                        Text("settings.install-uninstall.request-removal-confirmation.toggle")
                    }
                } label: {
                    Text("settings.install-uninstall.package-removal.label")
                }

                LabeledContent
                {
                    Defaults.Toggle(key: .includeGreedyOutdatedPackages)
                    {
                        Text("settings.install-uninstall.include-greedy-packages.toggle")
                    }
                } label: {
                    Text("settings.general.outdated-packages.info-amount")
                }

                LabeledContent
                {
                    Defaults.Toggle(key: .showCompatibilityWarning)
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
                            Defaults.Toggle(key: .showRealTimeTerminalOutputOfOperations)
                            {
                                Text("settings.install-uninstall.uninstallation.show-real-time-terminal-outputs")
                            }

                            Defaults.Toggle(key: .openRealTimeTerminalOutputByDefault)
                            {
                                Text("settings.install-uninstall.uninstallation.show-real-time-terminal-outputs.open-by-default")
                            }
                            .disabled(!showRealTimeTerminalOutputOfOperations)
                            .padding(.leading)
                        }

                        Defaults.Toggle(key: .automaticallyAcceptEULA)
                        {
                            Text("settings.install-uninstall.installation.automatically-accept-eulas")
                        }

                        VStack(alignment: .leading)
                        {
                            Defaults.Toggle(key: .allowMoreCompleteUninstallations)
                            {
                                Text("settings.install-uninstall.uninstallation.allow-more-complete-uninstallation")
                            }
                            .onChange(of: allowMoreCompleteUninstallations)
                            { _, newValue in
                                if newValue == true
                                {
                                    settingsState.alertType = .deepUninstall
                                    settingsState.isShowingAlert = true
                                }
                            }

                            HStack(alignment: .top)
                            {
                                Label("settings.install-uninstall.uninstallation.allow-more-complete-uninstallation.warning", systemImage: "exclamationmark.triangle")
                            }
                            .font(.caption)
                            .foregroundColor(Color(nsColor: NSColor.systemGray))
                        }
                        .disabled(!allowAdvancedHomebrewSettings)

                        VStack(alignment: .leading)
                        {
                            Defaults.Toggle(key: .isAutomaticCleanupEnabled)
                            {
                                Text("settings.install-uninstall.installation.enable-automatic-cleanup")
                            }
                            .onChange(of: isAutomaticCleanupEnabled)
                            { _, newValue in
                                if newValue == false
                                {
                                    settingsState.alertType = .cleanupDisabling
                                    settingsState.isShowingAlert = true
                                }
                            }

                            HStack(alignment: .top)
                            {
                                Label("settings.install-uninstall.installation.enable-automatic-cleanup.warning", systemImage: "exclamationmark.triangle")
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
