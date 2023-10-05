//
//  Finished.swift
//  Cork
//
//  Created by David Bureš on 05.10.2023.
//

import SwiftUI

struct PackageInstallationFinishedView: View
{
    @AppStorage("notifyAboutPackageInstallationResults") var notifyAboutPackageInstallationResults: Bool = false

    @EnvironmentObject var appState: AppState

    @Binding var isShowingSheet: Bool

    var body: some View
    {
        DisappearableSheet(isShowingSheet: $isShowingSheet)
        {
            ComplexWithIcon(systemName: "checkmark.seal")
            {
                HeadlineWithSubheadline(
                    headline: "add-package.finished",
                    subheadline: "add-package.finished.description",
                    alignment: .leading
                )
            }
        }
        .onAppear
        {
            appState.cachedDownloadsFolderSize = directorySize(url: AppConstants.brewCachedDownloadsPath)

            if notifyAboutPackageInstallationResults
            {
                sendNotification(title: String(localized: "notification.install-finished"))
            }
        }
    }
}

