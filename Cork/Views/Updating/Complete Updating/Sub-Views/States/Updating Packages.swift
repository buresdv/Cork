//
//  Updating Packages.swift
//  Cork
//
//  Created by David Bureš on 17.10.2023.
//

import SwiftUI
import CorkModels

struct UpdatingPackagesStateView: View
{
    @Environment(AppState.self) var appState: AppState
    @Environment(OutdatedPackagesTracker.self) var outdatedPackagesTracker: OutdatedPackagesTracker
    @Environment(UpdateProgressTracker.self) var updateProgressTracker: UpdateProgressTracker

    @Binding var packageUpdatingStep: PackageUpdatingProcessSteps

    @Binding var isShowingRealTimeTerminalOutput: Bool

    var body: some View
    {
        VStack(alignment: .leading)
        {
            VStack(alignment: .leading, spacing: 3)
            {
                Text("update-packages.updating.updating")
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)

                if let currentStage = updateProgressTracker.currentStage
                {
                    SubtitleText(text: currentStage.rawValue)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            LiveTerminalOutputView(
                lineArray: Bindable(updateProgressTracker).realTimeOutput,
                isRealTimeTerminalOutputExpanded: $isShowingRealTimeTerminalOutput
            )
        }
        .task
        {
            await updateProgressTracker.updatePackages()

            packageUpdatingStep = .updatingOutdatedPackageTracker
        }
    }
}
