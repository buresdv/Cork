//
//  Ready View.swift
//  Cork
//
//  Created by David Bureš on 25.02.2023.
//

import CorkShared
import SwiftUI
import Defaults

struct MaintenanceReadyView: View
{
    @Default(.default_shouldUninstallOrphans) var default_shouldUninstallOrphans: Bool
    @Default(.default_shouldPurgeCache) var default_shouldPurgeCache: Bool
    @Default(.default_shouldDeleteDownloads) var default_shouldDeleteDownloads: Bool
    @Default(.default_shouldPerformHealthCheck) var default_shouldPerformHealthCheck: Bool

    @Bindable var selectedMaintenanceStepsTracker: MaintenanceView.SelectedMaintenanceStepsTracker

    @Binding var maintenanceSteps: MaintenanceView.MaintenanceStage

    @State var isShowingControlButtons: Bool
    
    let fastCacheDeletion: Bool

    var enablePadding: Bool = true

    var body: some View
    {
        VStack(alignment: .leading, spacing: 10)
        {
            Form
            {
                LabeledContent("maintenance.steps.packages")
                {
                    VStack(alignment: .leading)
                    {
                        Toggle(isOn: $selectedMaintenanceStepsTracker.shouldUninstallOrphans)
                        {
                            Text("maintenance.steps.packages.uninstall-orphans")
                        }
                    }
                }

                LabeledContent("maintenance.steps.downloads")
                {
                    VStack(alignment: .leading)
                    {
                        Toggle(isOn: $selectedMaintenanceStepsTracker.shouldPurgeCache)
                        {
                            Text("maintenance.steps.downloads.purge-cache")
                        }
                        Toggle(isOn: $selectedMaintenanceStepsTracker.shouldDeleteDownloads)
                        {
                            Text("maintenance.steps.downloads.delete-cached-downloads")
                        }
                    }
                }

                LabeledContent("maintenance.steps.other")
                {
                    Toggle(isOn: $selectedMaintenanceStepsTracker.shouldPerformHealthCheck)
                    {
                        Text("maintenance.steps.other.health-check")
                    }
                }
            }
        }
        .onAppear
        {            
            if fastCacheDeletion
            {
                selectedMaintenanceStepsTracker.shouldDeleteDownloads = true
                selectedMaintenanceStepsTracker.shouldPerformHealthCheck = false
                selectedMaintenanceStepsTracker.shouldPurgeCache = false
                selectedMaintenanceStepsTracker.shouldUninstallOrphans = false
            }
        }
        .toolbar
        {
            if isShowingControlButtons
            {
                ToolbarItem(placement: .primaryAction)
                {
                    Button
                    {
                        AppConstants.shared.logger.debug("Start")

                        maintenanceSteps = .maintenanceRunning
                    } label: {
                        Text("maintenance.steps.start")
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(isStartDisabled)
                }
            }
        }
    }

    private var isStartDisabled: Bool
    {
        [selectedMaintenanceStepsTracker.shouldUninstallOrphans,
         selectedMaintenanceStepsTracker.shouldPurgeCache,
         selectedMaintenanceStepsTracker.shouldDeleteDownloads,
         selectedMaintenanceStepsTracker.shouldPerformHealthCheck].allSatisfy
        {
            !$0
        }
    }
}
