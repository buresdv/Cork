//
//  Menu Bar - Orphan Cleanup.swift
//  Cork
//
//  Created by David Bureš on 30.03.2024.
//

import SwiftUI

struct MenuBar_OrphanCleanup: View
{
    
    @EnvironmentObject var brewData: BrewDataStorage
    
    @State private var isUninstallingOrphanedPackages: Bool = false
    
    var body: some View
    {
        if !isUninstallingOrphanedPackages
        {
            Button("maintenance.steps.packages.uninstall-orphans")
            {
                Task(priority: .userInitiated)
                {
                    AppConstants.logger.log("Will delete orphans")

                    do
                    {
                        let orphanUninstallResult = try await uninstallOrphansUtility()

                        sendNotification(
                            title: String(localized: "maintenance.results.orphans-removed"),
                            body: String(localized: "maintenance.results.orphans-count-\(orphanUninstallResult)"),
                            sensitivity: .active
                        )
                    }
                    catch let orphanUninstallationError as OrphanRemovalError
                    {
                        AppConstants.logger.error("Failed while uninstalling orphans: \(orphanUninstallationError, privacy: .public)")

                        sendNotification(
                            title: String(localized: "maintenance.results.orphans.failure"),
                            body: String(localized: "maintenance.results.orphans.failure.details-\(orphanUninstallationError.localizedDescription)"),
                            sensitivity: .active
                        )
                    }

                    await synchronizeInstalledPackages(brewData: brewData)
                }
            }
        }
        else
        {
            Text("maintenance.step.removing-orphans")
        }
    }
}
