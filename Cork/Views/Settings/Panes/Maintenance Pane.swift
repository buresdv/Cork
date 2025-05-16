//
//  Maintenance Pane.swift
//  Cork
//
//  Created by David Bureš on 25.02.2023.
//

import SwiftUI
import Defaults

struct MaintenancePane: View
{
    @Default(.default_shouldUninstallOrphans) var default_shouldUninstallOrphans: Bool
    @Default(.default_shouldPurgeCache) var default_shouldPurgeCache: Bool
    @Default(.default_shouldDeleteDownloads) var default_shouldDeleteDownloads: Bool
    @Default(.default_shouldPerformHealthCheck) var default_shouldPerformHealthCheck: Bool

    @State var maintenanceStepsDummy: MaintenanceSteps = .ready

    var body: some View
    {
        SettingsPaneTemplate
        {
            VStack(alignment: .leading, spacing: 10)
            {
                Text("settings.maintenance.default-steps")
                    .font(.headline)
                MaintenanceReadyView(
                    shouldUninstallOrphans: $default_shouldUninstallOrphans,
                    shouldPurgeCache: $default_shouldPurgeCache,
                    shouldDeleteDownloads: $default_shouldDeleteDownloads,
                    shouldPerformHealthCheck: $default_shouldPerformHealthCheck,
                    maintenanceSteps: $maintenanceStepsDummy,
                    isShowingControlButtons: false,
                    forcedOptions: false,
                    enablePadding: false
                )
            }
        }
    }
}
