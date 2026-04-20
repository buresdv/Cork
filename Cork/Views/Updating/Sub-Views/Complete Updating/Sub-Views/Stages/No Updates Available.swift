//
//  No Updates Available.swift
//  Cork
//
//  Created by David Bureš on 17.10.2023.
//

import CorkNotifications
import CorkShared
import Defaults
import SwiftUI
import FactoryKit

struct NoUpdatesAvailableStageView: View
{
    @Default(.notifyAboutPackageUpgradeResults) var notifyAboutPackageUpgradeResults: Bool

    var body: some View
    {
        DisappearableSheet
        {
            ComplexWithIcon(systemName: "checkmark.seal")
            {
                HeadlineWithSubheadline(
                    headline: "update-packages.no-updates",
                    subheadline: "update-packages.no-updates.description",
                    alignment: .leading
                )
                .fixedSize()
            }
        }
        .onAppear
        {
            if notifyAboutPackageUpgradeResults
            {
                sendNotification(title: String(localized: "update-packages.no-updates"))
            }
        }
    }
}
