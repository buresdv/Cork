//
//  Maintenance View.swift
//  Cork
//
//  Created by David Bureš on 13.02.2023.
//

import CorkModels
import FactoryKit
import SwiftUI

typealias MaintenanceResults = MaintenanceFinishedView.MaintenanceResults

struct MaintenanceView: View
{
    enum MaintenanceStage
    {
        case ready, maintenanceRunning, finished(results: MaintenanceResults)

        var isDismissable: Bool
        {
            switch self
            {
            case .ready:
                return true
            case .maintenanceRunning:
                return false
            case .finished:
                return true
            }
        }

        var shouldShowTitle: Bool
        {
            switch self
            {
            case .ready:
                return true
            case .maintenanceRunning:
                return false
            case .finished:
                return false
            }
        }
    }

    enum HealthCheckStatus
    {
        case notRunYet
        case noProblemsFound
        case problemsFound(problems: [String])
    }

    @Environment(\.dismiss) var dismiss: DismissAction

    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker
    @InjectedObservable(\.appState) var appState: AppState

    @State var maintenanceSteps: MaintenanceStage = .ready

    @State var shouldPurgeCache: Bool = true
    @State var shouldDeleteDownloads: Bool = true
    @State var shouldUninstallOrphans: Bool = true
    @State var shouldPerformHealthCheck: Bool = false

    @State var numberOfOrphansRemoved: Int = 0

    @State var packagesHoldingBackCachePurge: [String] = .init()

    @State var brewHealthCheckStatus: HealthCheckStatus = .notRunYet

    @State var maintenanceFoundNoProblems: Bool = true

    @State var reclaimedSpaceAfterCachePurge: Int = 0

    @State var forcedOptions: Bool? = false

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
        switch maintenanceSteps
        {
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
            SheetTemplate(isShowingTitle: maintenanceSteps.shouldShowTitle)
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
                            healthCheckStatus: $brewHealthCheckStatus,
                            maintenanceSteps: $maintenanceSteps
                        )

                    case .finished(let results):
                        MaintenanceFinishedView(
                            maintenanceResults: results
                        )
                    }
                }
                .navigationTitle(sheetTitle)
                .toolbar
                {
                    if maintenanceSteps.isDismissable
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

extension MaintenanceView
{
    enum MaintenanceStep: MaintenanceActionable
    {
        case purgeCache
        case deleteDownloads(cachedDownloadsTracker: CachedDownloadsTracker, appState: AppState)
        case uninstallOrphans
        case performHealthCheck

        var actionName: LocalizedStringKey
        {
            switch self
            {
            case .purgeCache:
                return "maintenance.steps.downloads.purge-cache"
            case .deleteDownloads:
                return "maintenance.steps.downloads.delete-cached-downloads"
            case .uninstallOrphans:
                return "maintenance.steps.packages.uninstall-orphans"
            case .performHealthCheck:
                return "maintenance.steps.other.health-check"
            }
        }

        var actionInProgressName: LocalizedStringKey
        {
            switch self
            {
            case .purgeCache:
                return "maintenance.step.purging-cache"
            case .deleteDownloads:
                return "maintenance.step.deleting-cached-downloads"
            case .uninstallOrphans:
                return "maintenance.step.removing-orphans"
            case .performHealthCheck:
                return "maintenance.step.running-health-check"
            }
        }
    }
}
