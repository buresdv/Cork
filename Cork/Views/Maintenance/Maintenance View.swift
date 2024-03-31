//
//  Maintenance View.swift
//  Cork
//
//  Created by David Bureš on 13.02.2023.
//

import SwiftUI

enum MaintenanceSteps
{
    case ready, maintenanceRunning, finished
}

struct MaintenanceView: View
{
    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var appState: AppState

    @State var maintenanceSteps: MaintenanceSteps = .ready

    @State var shouldPurgeCache: Bool = true
    @State var shouldDeleteDownloads: Bool = true
    @State var shouldUninstallOrphans: Bool = true
    @State var shouldPerformHealthCheck: Bool = false

    @State var numberOfOrphansRemoved: Int = 0

    @State var packagesHoldingBackCachePurge: [String] = .init()

    @State var brewHealthCheckFoundNoProblems: Bool = false

    @State var maintenanceFoundNoProblems: Bool = true

    @State var reclaimedSpaceAfterCachePurge: Int = 0

    @State var forcedOptions: Bool? = false

    var body: some View
    {
        VStack(alignment: .leading, spacing: 10)
        {
            switch maintenanceSteps
            {
            case .ready:
                MaintenanceReadyView(
                    shouldUninstallOrphans: $shouldUninstallOrphans,
                    shouldPurgeCache: $shouldPurgeCache,
                    shouldDeleteDownloads: $shouldDeleteDownloads,
                    shouldPerformHealthCheck: $shouldPerformHealthCheck,
                    maintenanceSteps: $maintenanceSteps,
                    isShowingControlButtons: true,
                    forcedOptions: forcedOptions!
                )

            case .maintenanceRunning:
                MaintenanceRunningView(
                    shouldUninstallOrphans: shouldUninstallOrphans,
                    shouldPurgeCache: shouldPurgeCache,
                    shouldDeleteDownloads: shouldDeleteDownloads,
                    shouldPerformHealthCheck: shouldPerformHealthCheck,
                    numberOfOrphansRemoved: $numberOfOrphansRemoved,
                    packagesHoldingBackCachePurge: $packagesHoldingBackCachePurge, 
                    reclaimedSpaceAfterCachePurge: $reclaimedSpaceAfterCachePurge,
                    brewHealthCheckFoundNoProblems: $brewHealthCheckFoundNoProblems,
                    maintenanceSteps: $maintenanceSteps
                )

            case .finished:
                MaintenanceFinishedView(
                    shouldUninstallOrphans: shouldUninstallOrphans,
                    shouldPurgeCache: shouldPurgeCache,
                    shouldDeleteDownloads: shouldDeleteDownloads,
                    shouldPerformHealthCheck: shouldPerformHealthCheck,
                    packagesHoldingBackCachePurge: packagesHoldingBackCachePurge, 
                    numberOfOrphansRemoved: numberOfOrphansRemoved,
                    reclaimedSpaceAfterCachePurge: reclaimedSpaceAfterCachePurge,
                    brewHealthCheckFoundNoProblems: brewHealthCheckFoundNoProblems,
                    maintenanceFoundNoProblems: $maintenanceFoundNoProblems
                )
            }
        }
    }
}
