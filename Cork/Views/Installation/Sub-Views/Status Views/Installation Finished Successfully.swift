//
//  Installation Finished Successfully.swift
//  Cork
//
//  Created by David Bureš - P on 25.01.2025.
//

import CorkNotifications
import CorkShared
import SwiftUI
import Defaults

struct InstallationFinishedSuccessfullyView: View
{
    @Environment(CachedDownloadsTracker.self) var cachedDownloadsTracker: CachedDownloadsTracker

    @Default(.notifyAboutPackageInstallationResults) var notifyAboutPackageInstallationResults: Bool

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
