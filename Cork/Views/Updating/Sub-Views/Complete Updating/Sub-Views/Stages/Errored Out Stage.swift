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
import CorkModels
import FactoryKit

struct ErroredOutStageView: View
{
    @Default(.notifyAboutPackageUpgradeResults) var notifyAboutPackageUpgradeResults: Bool
    
    @Environment(\.dismiss) var dismiss: DismissAction
    
    @InjectedObservable(\.appState) var appState: AppState
    @Environment(UpdateProgressTracker.self) var updateProgressTracker: UpdateProgressTracker
    
    let errors: [OutdatedPackagesTracker.IndividualPackageUpdatingError]
    
    var body: some View
    {
        ComplexWithIcon(systemName: "seal")
        {
            VStack(alignment: .leading, spacing: 10)
            {
                HeadlineWithSubheadline(
                    headline: "update-packages.failed.title",
                    subheadline: "update-packages.failed.message",
                    alignment: .leading
                )
                
                UpdateResultsList(updateErrors: errors)
            }
        }
    }
}
