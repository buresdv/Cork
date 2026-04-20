//
//  Update Progress Tracker.swift
//  Cork
//
//  Created by David Bureš on 04.07.2022.
//

import CorkModels
import CorkTerminalFunctions
import FactoryKit
import Foundation
import SwiftUI

@Observable @MainActor
public class UpdateProgressTracker: @MainActor TerminalOutputStreamable
{
    public var outputs: [CorkTerminalFunctions.TerminalOutput]

    @Injected(\.appConstants) @ObservationIgnored var appConstants

    public var isStreamedOutputExpanded: Bool = false

    var updateProgress: Progress

    let outdatedPackagesTrackerToUse: OutdatedPackagesTracker

    let packageUpdatingType: UpdatePackagesView.UpdateType

    var updatingState: PackageUpdatingStage
    
    var packageBeingCurrentlyUpdated: OutdatedPackage?

    enum PackageUpdatingStage
    {
        case updating(type: UpdatePackagesView.UpdateType)
        case finished
        case erroredOut(results: [OutdatedPackagesTracker.IndividualPackageUpdatingError])
        case noUpdatesAvailable
    }
    
    public init(
        outdatedPackagesTrackerToUse: OutdatedPackagesTracker
    ) {
        self.outputs = []
        self.packageBeingCurrentlyUpdated = nil

        self.outdatedPackagesTrackerToUse = outdatedPackagesTrackerToUse
        
        self.updateProgress = Progress(totalUnitCount: Int64(self.outdatedPackagesTrackerToUse.packagesMarkedForUpdating.count))
        
        self.packageUpdatingType = {
            if outdatedPackagesTrackerToUse.areAllOutdatedPackagesMarkedForUpdating
            {
                return .complete
            }
            else
            {
                return .partial(packagesToUpdate: outdatedPackagesTrackerToUse.packagesMarkedForUpdating)
            }
        }()

        self.updatingState = .updating(type: self.packageUpdatingType)
    }
}
