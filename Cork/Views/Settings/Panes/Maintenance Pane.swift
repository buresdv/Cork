//
//  Maintenance Pane.swift
//  Cork
//
//  Created by David Bureš on 25.02.2023.
//

import SwiftUI

struct MaintenancePane: View
{
    @AppStorage("default_shouldUninstallOrphans") var default_shouldUninstallOrphans: Bool = true
    @AppStorage("default_shouldPurgeCache") var default_shouldPurgeCache: Bool = true
    @AppStorage("default_shouldDeleteDownloads") var default_shouldDeleteDownloads: Bool = true
    @AppStorage("default_shouldPerformHealthCheck") var default_shouldPerformHealthCheck: Bool = false

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
