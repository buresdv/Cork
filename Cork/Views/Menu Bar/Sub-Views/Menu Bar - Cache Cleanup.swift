//
//  Menu Bar - Cache Cleanup.swift
//  Cork
//
//  Created by David Bureš on 30.03.2024.
//

import SwiftUI

struct MenuBar_CacheCleanup: View
{
    
    @State private var isPurgingHomebrewCache: Bool = false
    
    var body: some View
    {
        if !isPurgingHomebrewCache
        {
            Button("maintenance.steps.downloads.purge-cache")
            {
                Task(priority: .userInitiated)
                {
                    AppConstants.logger.log("Will purge cache")

                    isPurgingHomebrewCache = true

                    defer
                    {
                        isPurgingHomebrewCache = false
                    }

                    do
                    {
                        let packagesHoldingBackCachePurge = try await purgeHomebrewCacheUtility()

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
                        AppConstants.logger.warning("There were errors while purging Homebrew cache: \(cachePurgingError.localizedDescription, privacy: .public)")

                        sendNotification(
                            title: String(localized: "maintenance.results.package-cache.failure"),
                            body: String(localized: "maintenance.results.package-cache.failure.details-\(cachePurgingError.localizedDescription)"),
                            sensitivity: .active
                        )
                    }
                }
            }
        }
        else
        {
            Text("maintenance.step.purging-cache")
        }
    }
}
