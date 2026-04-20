//
//  Updating Packages.swift
//  Cork
//
//  Created by David Bureš on 17.10.2023.
//

import SwiftUI
import CorkModels
import FactoryKit

/*
struct UpdatingPackagesStateView: View
{
    @InjectedObservable(\.appState) var appState: AppState
    @Environment(OutdatedPackagesTracker.self) var outdatedPackagesTracker: OutdatedPackagesTracker
    @Environment(UpdateProgressTracker.self) var updateProgressTracker: UpdateProgressTracker

    var body: some View
    {
        VStack(alignment: .leading)
        {
            VStack(alignment: .leading, spacing: 3)
            {
                Text("update-packages.updating.updating")
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)

                if let currentStage = updateProgressTracker.updatingState
                {
                    SubtitleText(text: currentStage.rawValue)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            updateProgressTracker.streamedOutputsDisplay
        }
        .task
        {
            await updateProgressTracker.updatePackages()

            packageUpdatingStep = .updatingOutdatedPackageTracker
        }
    }
}
*/
