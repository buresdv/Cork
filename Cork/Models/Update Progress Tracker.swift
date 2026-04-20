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

@Observable
public class UpdateProgressTracker: @MainActor TerminalOutputStreamable
{
    public var outputs: [CorkTerminalFunctions.TerminalOutput]

    @Injected(\.appConstants) @ObservationIgnored var appConstants

    public var isStreamedOutputExpanded: Bool = false

    var updateProgress: Progress

    let outdatedPackagesTrackerToUse: OutdatedPackagesTracker

    let packageUpdatingType: UpdatePackagesView.UpdateType

    public nonisolated init(
        outdatedPackagesTrackerToUse: OutdatedPackagesTracker
    ) {
        self.outdatedPackagesTrackerToUse = outdatedPackagesTrackerToUse
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
    }
}
