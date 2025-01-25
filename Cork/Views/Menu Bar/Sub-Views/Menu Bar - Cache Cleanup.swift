//
//  Menu Bar - Cache Cleanup.swift
//  Cork
//
//  Created by David Bureš on 30.03.2024.
//

import SwiftUI
import CorkShared
import CorkNotifications
import ButtonKit

struct MenuBar_CacheCleanup: View
{
    @State private var isPurgingHomebrewCache: Bool = false

    var body: some View
    {
        if !isPurgingHomebrewCache
        {
            AsyncButton
            {
                AppConstants.shared.logger.log("Will purge cache")

                isPurgingHomebrewCache = true

                defer
                {
                    isPurgingHomebrewCache = false
                }

                do
                {
                    let packagesHoldingBackCachePurge: [String] = try await purgeHomebrewCacheUtility()

                    if packagesHoldingBackCachePurge.isEmpty
                    {
                        sendNotification(
                            title: String(localized: "maintenance.results.package-cache"),
                            sensitivity: .active
                        )
                    }
                    else
                    {
                        sendNotification(
                            title: String(localized: "maintenance.results.package-cache"),
                            body: String(localized: "maintenance.results.package-cache.skipped-\(packagesHoldingBackCachePurge.formatted(.list(type: .and)))"),
                            sensitivity: .active
                        )
                    }
                }
                catch let cachePurgingError
                {
                    AppConstants.shared.logger.warning("There were errors while purging Homebrew cache: \(cachePurgingError.localizedDescription, privacy: .public)")

                    sendNotification(
                        title: String(localized: "maintenance.results.package-cache.failure"),
                        body: String(localized: "maintenance.results.package-cache.failure.details-\(cachePurgingError.localizedDescription)"),
                        sensitivity: .active
                    )
                }
            } label: {
                Text("maintenance.steps.downloads.purge-cache")
            }
        }
        else
        {
            Text("maintenance.step.purging-cache")
        }
    }
}
