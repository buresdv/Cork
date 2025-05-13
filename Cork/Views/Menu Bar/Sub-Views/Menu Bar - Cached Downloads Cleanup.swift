//
//  Menu Bar - Cached Downloads Cleanup.swift
//  Cork
//
//  Created by David Bureš on 30.03.2024.
//

import SwiftUI
import CorkShared
import CorkNotifications

struct MenuBar_CachedDownloadsCleanup: View
{
    @Environment(AppState.self) var appState: AppState

    @EnvironmentObject var cachedDownloadsTracker: CachedPackagesTracker
    
    @State private var isDeletingCachedDownloads: Bool = false

    var body: some View
    {
        if !isDeletingCachedDownloads
        {
            Button(cachedDownloadsTracker.cachedDownloadsSize != 0 ? "maintenance.steps.downloads.delete-cached-downloads" : "navigation.menu.maintenance.no-cached-downloads")
            {
                AppConstants.shared.logger.log("Will delete cached downloads")

                isDeletingCachedDownloads = true

                let reclaimedSpaceAfterCachePurge: Int = .init(cachedDownloadsTracker.cachedDownloadsSize)

                do throws(CachedDownloadDeletionError)
                {
                    try deleteCachedDownloads()
                }
                catch let cacheDeletionError
                {
                    switch cacheDeletionError
                    {
                    case .couldNotReadContentsOfCachedFormulaeDownloadsFolder(let associatedError):
                        appState.showAlert(errorToShow: .couldNotDeleteCachedDownloads(error: associatedError))
                        
                    case .couldNotReadContentsOfCachedCasksDownloadsFolder(let associatedError):
                        appState.showAlert(errorToShow: .couldNotDeleteCachedDownloads(error: associatedError))
                        
                    case .couldNotReadContentsOfCachedDownloadsFolder(let associatedError):
                        appState.showAlert(errorToShow: .couldNotDeleteCachedDownloads(error: associatedError))
                    }
                }

                sendNotification(
                    title: String(localized: "maintenance.results.cached-downloads"),
                    body: String(localized: "maintenance.results.cached-downloads.summary-\(reclaimedSpaceAfterCachePurge.formatted(.byteCount(style: .file)))"),
                    sensitivity: .active
                )

                isDeletingCachedDownloads = false
            }
            .disabled(cachedDownloadsTracker.cachedDownloadsSize == 0)
        }
        else
        {
            Text("maintenance.step.deleting-cached-downloads")
        }
    }
}
