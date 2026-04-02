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
                return true
            }
        }
    }

    enum HealthCheckStatus
    {
        case notRunYet
        case noProblemsFound
        case problemsFound(problems: [String])
    }

    @Observable
    class SelectedMaintenanceStepsTracker
    {
        var shouldPurgeCache: Bool = true
        var shouldDeleteDownloads: Bool = true
        var shouldUninstallOrphans: Bool = true
        var shouldPerformHealthCheck: Bool = false
    }

    @Environment(\.dismiss) var dismiss: DismissAction

    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker
    @InjectedObservable(\.appState) var appState: AppState

    @State var maintenanceSteps: MaintenanceStage = .ready

    @State private var selectedMaintenanceStepsTracker: SelectedMaintenanceStepsTracker = .init()

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
            return "maintenance.finished"
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
                maintenanceStepsViews
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

    @ViewBuilder
    var maintenanceStepsViews: some View
    {
        switch maintenanceSteps
        {
        case .ready:
            MaintenanceReadyView(
                selectedMaintenanceStepsTracker: selectedMaintenanceStepsTracker,
                maintenanceSteps: $maintenanceSteps,
                isShowingControlButtons: true,
                forcedOptions: forcedOptions!
            )

        case .maintenanceRunning:
            MaintenanceRunningView(
                maintenanceSteps: $maintenanceSteps,
                selectedMaintenanceStepsTracker: selectedMaintenanceStepsTracker
            )

        case .finished(let results):
            MaintenanceFinishedView(
                selectedMaintenanceStepsTracker: selectedMaintenanceStepsTracker,
                maintenanceResults: results
            )
        }
    }
}

extension MaintenanceView
{
    enum MaintenanceStep: MaintenanceActionable
    {
        case purgeCache
        case deleteDownloads
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
