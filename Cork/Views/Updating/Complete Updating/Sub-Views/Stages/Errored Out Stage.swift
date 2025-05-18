//
//  Errored Out Stage.swift
//  Cork
//
//  Created by David Bureš on 17.10.2023.
//

import CorkNotifications
import CorkShared
import Defaults
import SwiftUI

struct ErroredOutStageView: View
{
    @Default(.notifyAboutPackageUpgradeResults) var notifyAboutPackageUpgradeResults: Bool

    @Environment(\.dismiss) var dismiss: DismissAction

    @Environment(AppState.self) var appState: AppState
    @EnvironmentObject var updateProgressTracker: UpdateProgressTracker

    let sudoRequiredForUpdate: Bool

    var body: some View
    {
        ComplexWithIcon(systemName: "checkmark.seal")
        {
            VStack(alignment: .leading, spacing: 5)
            {
                if !sudoRequiredForUpdate
                {
                    updatedWithErrorsNoSudoNeeded
                }
                else
                {
                    updatedWithErrorSudoIsNeeded
                }

                HStack
                {
                    DismissSheetButton(customButtonText: "action.close")

                    Spacer()

                    Button
                    {
                        "brew update".copyToClipboard()

                        openTerminal()

                        dismiss()
                    } label: {
                        Text("action.finish-updating-in-terminal")
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
            .fixedSize()
            .onAppear
            {
                AppConstants.shared.logger.error("Update errors: \(updateProgressTracker.errors)")
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

    @ViewBuilder
    var updatedWithErrorsNoSudoNeeded: some View
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
    }

    @ViewBuilder
    var updatedWithErrorSudoIsNeeded: some View
    {
        HeadlineWithSubheadline(
            headline: "update-packages.error.sudo-required",
            subheadline: "update-packages.error.sudo-required.description",
            alignment: .leading
        )
    }
}
