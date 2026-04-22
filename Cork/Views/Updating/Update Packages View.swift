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
    enum UpdateType
    {
        case partial(packagesToUpdate: [OutdatedPackage])
        case complete
    }

    let outdatedPackagesTrackerToUse: OutdatedPackagesTracker
    
    @State private var updateProgressTracker: UpdateProgressTracker
    
    @MainActor
    init(outdatedPackagesTrackerToUse: OutdatedPackagesTracker)
    {
        self.outdatedPackagesTrackerToUse = outdatedPackagesTrackerToUse
        _updateProgressTracker = State(initialValue: UpdateProgressTracker(outdatedPackagesTrackerToUse: outdatedPackagesTrackerToUse))
    }

    var body: some View
    {
        NavigationStack
        {
            SheetTemplate(isShowingTitle: true)
            {
                switch updateProgressTracker.updatingState
                {
                case .updating(let type):
                    switch type
                    {
                    case .partial(let packagesToUpdate):
                        UpdateSomePackagesView(packagesToUpdate: packagesToUpdate)
                    case .complete:
                        EmptyView()
                    }
                case .finished:
                    FinishedStageView()
                case .erroredOut(let results):
                    ErroredOutStageView(errors: results)
                case .noUpdatesAvailable:
                    NoUpdatesAvailableStageView()
                }
            }
            .navigationTitle("update-packages.sheet-title")
        }
        .environment(updateProgressTracker)
    }
}
