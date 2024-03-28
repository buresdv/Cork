//
//  Errored Out Stage.swift
//  Cork
//
//  Created by David Bureš on 17.10.2023.
//

import SwiftUI

struct ErroredOutStageView: View
{
    @AppStorage("notifyAboutPackageUpgradeResults") var notifyAboutPackageUpgradeResults: Bool = false

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var updateProgressTracker: UpdateProgressTracker

    var body: some View
    {
        ComplexWithIcon(systemName: "checkmark.seal")
        {
            VStack(alignment: .leading, spacing: 5)
            {
                HeadlineWithSubheadline(
                    headline: "update-packages.error",
                    subheadline: "update-packages.error.description",
                    alignment: .leading
                )
                List
                {
                    ForEach(updateProgressTracker.errors, id: \.self)
                    { error in
                        HStack(alignment: .firstTextBaseline, spacing: 5)
                        {
                            Text("⚠️")
                            Text(error)
                        }
                    }
                }
                .listStyle(.bordered(alternatesRowBackgrounds: false))
                .frame(height: 100, alignment: .leading)
                HStack
                {
                    Spacer()
                    DismissSheetButton(customButtonText: "action.close")
                }
            }
            .fixedSize()
            .onAppear
            {
                AppConstants.logger.error("Update errors: \(updateProgressTracker.errors)")
            }
        }
        .onAppear
        {
            if notifyAboutPackageUpgradeResults
            {
                sendNotification(title: String(localized: "notification.upgrade-finished.success"), body: String(localized: "notification.upgrade-finished.success.some-errors"))
            }
        }
    }
}
