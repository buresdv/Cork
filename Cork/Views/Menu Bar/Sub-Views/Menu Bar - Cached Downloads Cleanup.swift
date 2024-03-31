//
//  Menu Bar - Cached Downloads Cleanup.swift
//  Cork
//
//  Created by David Bureš on 30.03.2024.
//

import SwiftUI

struct MenuBar_CachedDownloadsCleanup: View
{
    @EnvironmentObject var appState: AppState
    
    @State private var isDeletingCachedDownloads: Bool = false
    
    var body: some View
    {
        if !isDeletingCachedDownloads
        {
            Button(appState.cachedDownloadsFolderSize != 0 ? "maintenance.steps.downloads.delete-cached-downloads" : "navigation.menu.maintenance.no-cached-downloads")
            {
                AppConstants.logger.log("Will delete cached downloads")

                isDeletingCachedDownloads = true

                let reclaimedSpaceAfterCachePurge = Int(appState.cachedDownloadsFolderSize)

                deleteCachedDownloads()

                sendNotification(
                    title: String(localized: "maintenance.results.cached-downloads"),
                    body: String(localized: "maintenance.results.cached-downloads.summary-\(reclaimedSpaceAfterCachePurge.formatted(.byteCount(style: .file)))"),
                    sensitivity: .active
                )

                isDeletingCachedDownloads = false

                appState.cachedDownloadsFolderSize = directorySize(url: AppConstants.brewCachedDownloadsPath)
            }
            .disabled(appState.cachedDownloadsFolderSize == 0)
        }
        else
        {
            Text("maintenance.step.deleting-cached-downloads")
        }
    }
}
