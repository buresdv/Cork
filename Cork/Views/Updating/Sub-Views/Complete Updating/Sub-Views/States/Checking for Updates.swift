//
//  Checking for Updates.swift
//  Cork
//
//  Created by David Bureš on 17.10.2023.
//

import SwiftUI
import CorkShared
import CorkModels
import FactoryKit

struct CheckingForUpdatesStateView: View
{
    @InjectedObservable(\.outdatedPackagesTracker) var outdatedPackagesTracker: OutdatedPackagesTracker
    @Environment(UpdateProgressTracker.self) var updateProgressTracker: UpdateProgressTracker

    @Binding var updateAvailability: OutdatedPackagesTracker.PackageUpdateAvailability

    @Binding var isShowingRealTimeTerminalOutput: Bool

    var body: some View
    {
        VStack(alignment: .leading)
        {
            Text("update-packages.updating.checking")
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            updateProgressTracker.streamedOutputsDisplay
        }
        .task
        {
            updateAvailability = await outdatedPackagesTracker.refreshPackages(
                updateProgressTracker: updateProgressTracker
            )

            AppConstants.shared.logger.debug("Update availability result: \(updateAvailability.description, privacy: .public)")

            if updateAvailability == .noUpdatesAvailable
            {
                AppConstants.shared.logger.debug("Outside update function: No updates available")

                updateProgressTracker.updatingState = .noUpdatesAvailable
            }
            else
            {
                AppConstants.shared.logger.debug("Outside update function: Updates available")
                
                updateProgressTracker.updatingState = .updating(type: updateProgressTracker.packageUpdatingType)
            }
        }
    }
}
