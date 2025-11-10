//
//  Maintenance View.swift
//  Cork
//
//  Created by David Bureš on 13.02.2023.
//

import SwiftUI
import CorkModels

enum MaintenanceSteps
{
    case ready, maintenanceRunning, finished
}

struct MaintenanceView: View
{
    @Environment(\.dismiss) var dismiss: DismissAction
    
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker
    @Environment(AppState.self) var appState: AppState

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
    
    var isDismissable: Bool
    {
        [.ready, .finished].contains(maintenanceSteps)
    }
    
    var shouldShowTitle: Bool
    {
        [.ready].contains(maintenanceSteps)
    }
    
    var sheetTitle: LocalizedStringKey
    {
        switch maintenanceSteps
        {
        case .ready:
            return "maintenance.title"
        case .maintenanceRunning:
            return ""
        case .finished:
            return ""
        }
    }
    
    var dismissButtonTitle: LocalizedStringKey
    {
        switch maintenanceSteps {
        case .ready:
            return "action.cancel"
        case .maintenanceRunning:
            return ""
        case .finished:
            return "action.close"
        }
    }

    var body: some View
    {
        NavigationStack
        {
            SheetTemplate(isShowingTitle: shouldShowTitle)
            {
                Group
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
                .navigationTitle(sheetTitle)
                .toolbar
                {
                    if isDismissable
                    {
                        ToolbarItem(placement: .cancellationAction)
                        {
                            Button
                            {
                                dismiss()
                            } label: {
                                Text(dismissButtonTitle)
                            }
                            .keyboardShortcut(.cancelAction)
                        }
                    }
                }
            }
        }
    }
}
