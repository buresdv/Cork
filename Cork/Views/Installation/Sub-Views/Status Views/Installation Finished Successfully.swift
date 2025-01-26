//
//  Installation Finished Successfully.swift
//  Cork
//
//  Created by David Bureš - P on 25.01.2025.
//

import CorkNotifications
import CorkShared
import SwiftUI

struct InstallationFinishedSuccessfullyView: View
{
    @EnvironmentObject var cachedDownloadsTracker: CachedPackagesTracker

    @AppStorage("notifyAboutPackageInstallationResults") var notifyAboutPackageInstallationResults: Bool = false

    var body: some View
    {
        DisappearableSheet
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
            if notifyAboutPackageInstallationResults
            {
                sendNotification(
                    title: String(localized: "notification.install-finished"))
            }
        }
    }
}
