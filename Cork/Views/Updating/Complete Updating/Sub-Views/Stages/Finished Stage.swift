//
//  Finished Stage .swift
//  Cork
//
//  Created by David Bureš on 17.10.2023.
//

import CorkNotifications
import Defaults
import SwiftUI
import FactoryKit

struct FinishedStageView: View
{
    @Default(.notifyAboutPackageUpgradeResults) var notifyAboutPackageUpgradeResults: Bool

    var body: some View
    {
        DisappearableSheet
        {
            ComplexWithIcon(systemName: "checkmark.seal")
            {
                HeadlineWithSubheadline(
                    headline: "update-packages.finished",
                    subheadline: "update-packages.finished.description",
                    alignment: .leading
                )
                .fixedSize()
            }
        }
        .onAppear
        {
            if notifyAboutPackageUpgradeResults
            {
                sendNotification(title: String(localized: "notification.upgrade-finished.success"))
            }
        }
    }
}
