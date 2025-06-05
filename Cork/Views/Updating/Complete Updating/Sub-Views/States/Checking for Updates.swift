//
//  Checking for Updates.swift
//  Cork
//
//  Created by David Bureš on 17.10.2023.
//

import SwiftUI
import CorkShared

struct CheckingForUpdatesStateView: View
{
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker
    @EnvironmentObject var updateProgressTracker: UpdateProgressTracker

    @Binding var packageUpdatingStep: PackageUpdatingProcessSteps
    @Binding var packageUpdatingStage: PackageUpdatingStage

    @Binding var updateAvailability: PackageUpdateAvailability

    @Binding var isShowingRealTimeTerminalOutput: Bool

    var body: some View
    {
        VStack(alignment: .leading)
        {
            Text("update-packages.updating.checking")
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            LiveTerminalOutputView(
                lineArray: $updateProgressTracker.realTimeOutput,
                isRealTimeTerminalOutputExpanded: $isShowingRealTimeTerminalOutput,
                forceKeepTerminalOutputInMemory: true
            )
        }
        .task
        {
            updateAvailability = await refreshPackages(updateProgressTracker, outdatedPackageTracker: outdatedPackageTracker)

            AppConstants.shared.logger.debug("Update availability result: \(updateAvailability.description, privacy: .public)")

            if updateAvailability == .noUpdatesAvailable
            {
                AppConstants.shared.logger.debug("Outside update function: No updates available")

                updateProgressTracker.realTimeOutput = .init()

                packageUpdatingStage = .noUpdatesAvailable
            }
            else
            {
                AppConstants.shared.logger.debug("Outside update function: Updates available")
                packageUpdatingStep = .updatingPackages
            }
        }
    }
}
