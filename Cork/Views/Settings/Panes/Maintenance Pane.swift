//
//  Maintenance Pane.swift
//  Cork
//
//  Created by David Bureš on 25.02.2023.
//

import SwiftUI
import Defaults
import CorkModels

struct MaintenancePane: View
{
    @Default(.default_shouldUninstallOrphans) var default_shouldUninstallOrphans: Bool
    @Default(.default_shouldPurgeCache) var default_shouldPurgeCache: Bool
    @Default(.default_shouldDeleteDownloads) var default_shouldDeleteDownloads: Bool
    @Default(.default_shouldPerformHealthCheck) var default_shouldPerformHealthCheck: Bool

    @State var maintenanceStepsDummy: MaintenanceView.MaintenanceStage = .ready
    
    @Environment(SettingsState.self) var settingsState: SettingsState

    var body: some View
    {
        
        SettingsPaneTemplate
        {
            VStack(alignment: .leading, spacing: 10)
            {
                Text("settings.maintenance.default-steps")
                    .font(.headline)
                
                MaintenanceSettingsView()
            }
        }
    }
}

private struct MaintenanceSettingsView: View
{
    @Default(.default_shouldUninstallOrphans) var shouldUninstallOrphans: Bool
    @Default(.default_shouldPurgeCache) var shouldPurgeCache: Bool
    @Default(.default_shouldDeleteDownloads) var shouldDeleteDownloads: Bool
    @Default(.default_shouldPerformHealthCheck) var shouldPerformHealthCheck: Bool

    var body: some View
    {
        Form
        {
            LabeledContent("maintenance.steps.packages")
            {
                VStack(alignment: .leading)
                {
                    Toggle(isOn: $shouldUninstallOrphans)
                    {
                        Text("maintenance.steps.packages.uninstall-orphans")
                    }
                }
            }

            LabeledContent("maintenance.steps.downloads")
            {
                VStack(alignment: .leading)
                {
                    Toggle(isOn: $shouldPurgeCache)
                    {
                        Text("maintenance.steps.downloads.purge-cache")
                    }
                    Toggle(isOn: $shouldDeleteDownloads)
                    {
                        Text("maintenance.steps.downloads.delete-cached-downloads")
                    }
                }
            }

            LabeledContent("maintenance.steps.other")
            {
                Toggle(isOn: $shouldPerformHealthCheck)
                {
                    Text("maintenance.steps.other.health-check")
                }
            }
        }
    }
}
