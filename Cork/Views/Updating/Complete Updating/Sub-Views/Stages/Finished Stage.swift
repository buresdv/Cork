//
//  Finished Stage .swift
//  Cork
//
//  Created by David Bureš on 17.10.2023.
//

import SwiftUI

struct FinishedStageView: View {
    
    @AppStorage("notifyAboutPackageUpgradeResults") var notifyAboutPackageUpgradeResults: Bool = false

    var body: some View {
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
