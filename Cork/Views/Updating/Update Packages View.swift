//
//  Update Packages View.swift
//  Cork
//
//  Created by David Bureš - P on 18.04.2026.
//

import CorkModels
import CorkTerminalFunctions
import SwiftUI

struct UpdatePackagesView: View
{
    @Environment(OutdatedPackagesTracker.self) var outdatedPackagesTracker

    enum UpdateType
    {
        case partial(packagesToUpdate: [OutdatedPackage])
        case complete
    }

    var updateType: UpdateType
    {
        if outdatedPackagesTracker.areAllOutdatedPackagesMarkedForUpdating
        {
            return complete
        }
        else
        {
            return partial(packagesToUpdate: outdatedPackagesTracker.packagesMarkedForUpdating)
        }
    }

    @State private var updateProgressTracker: UpdateProgressTracker = .init()

    var body: some View
    {
        Group
        {
            switch updateProgressTracker.packageUpdatingState
            {
            case .ready:
                ProgressView()
            case .updating(let type):
                switch type
                {
                case .partial(let packagesToUpdate):
                    UpdateSomePackagesView(packagesToUpdate: packagesToUpdate)
                case .complete:
                    UpdateAllPackagesView()
                }
            case .finished:
                FinishedStageView()
            case .erroredOut(let results):
                ErroredOutStageView(errors: results)
            case .noUpdatesAvailable:
                NoUpdatesAvailableStageView()
            }
        }
        .environment(updateProgressTracker)
    }
}
