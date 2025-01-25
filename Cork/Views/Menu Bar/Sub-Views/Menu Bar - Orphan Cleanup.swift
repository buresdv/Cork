//
//  Menu Bar - Orphan Cleanup.swift
//  Cork
//
//  Created by David Bureš on 30.03.2024.
//

import ButtonKit
import CorkNotifications
import CorkShared
import SwiftUI

struct MenuBar_OrphanCleanup: View
{
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var brewData: BrewDataStorage

    @State private var isUninstallingOrphanedPackages: Bool = false

    var body: some View
    {
        if !isUninstallingOrphanedPackages
        {
            AsyncButton
            {
                AppConstants.shared.logger.log("Will delete orphans")

                do
                {
                    let orphanUninstallResult: Int = try await uninstallOrphansUtility()

                    sendNotification(
                        title: String(localized: "maintenance.results.orphans-removed"),
                        body: String(localized: "maintenance.results.orphans-count-\(orphanUninstallResult)"),
                        sensitivity: .active
                    )
                }
                catch let orphanUninstallationError
                {
                    AppConstants.shared.logger.error("Failed while uninstalling orphans: \(orphanUninstallationError, privacy: .public)")

                    sendNotification(
                        title: String(localized: "maintenance.results.orphans.failure"),
                        body: String(localized: "maintenance.results.orphans.failure.details-\(orphanUninstallationError.localizedDescription)"),
                        sensitivity: .active
                    )
                }

                do
                {
                    try await brewData.synchronizeInstalledPackages()
                }
                catch let synchronizationError
                {
                    appState.showAlert(errorToShow: .couldNotSynchronizePackages(error: synchronizationError.localizedDescription))
                }
            } label: {
                Text("maintenance.steps.packages.uninstall-orphans")
            }
        }
        else
        {
            Text("maintenance.step.removing-orphans")
        }
    }
}
