//
//  Update Packages.swift
//  Cork
//
//  Created by David Bureš on 09.03.2023.
//

import SwiftUI

struct UpdatePackagesView: View
{
    @State var packageUpdatingStage: PackageUpdatingStage = .updating
    @State var packageUpdatingStep: PackageUpdatingProcessSteps = .ready

    @State var updateAvailability: PackageUpdateAvailability = .updatesAvailable
    
    @EnvironmentObject var updateProgressTracker: UpdateProgressTracker

    @StateObject var updateProcessDetailsStage: UpdatingProcessDetails = .init()

    @State private var isRealTimeTerminalOutputExpanded: Bool = false

    var body: some View
    {
        VStack(alignment: .leading, spacing: 10)
        {
            switch packageUpdatingStage
            {
            case .updating:
                ProgressView(value: updateProgressTracker.updateProgress, total: 10)
                {
                    switch packageUpdatingStep
                    {
                    case .ready:
                        ReadyToUpdateStateView(
                            packageUpdatingStep: $packageUpdatingStep
                        )

                    case .checkingForUpdates:
                        CheckingForUpdatesStateView(
                            packageUpdatingStep: $packageUpdatingStep,
                            packageUpdatingStage: $packageUpdatingStage, 
                            updateAvailability: $updateAvailability, 
                            isShowingRealTimeTerminalOutput: $isRealTimeTerminalOutputExpanded
                        )

                    case .updatingPackages:
                        UpdatingPackagesStateView(
                            updateProcessDetailsStage: updateProcessDetailsStage,
                            packageUpdatingStep: $packageUpdatingStep,
                            isShowingRealTimeTerminalOutput: $isRealTimeTerminalOutputExpanded
                        )

                    case .updatingOutdatedPackageTracker:
                            UpdatingPackageTrackerStateView(
                                packageUpdatingStage: $packageUpdatingStage
                            )

                    case .finished:
                        UpdatingFinishedStateView(
                            packageUpdatingStep: $packageUpdatingStep
                        )
                    }
                }

            case .noUpdatesAvailable:
                NoUpdatesAvailableStageView()

            case .finished:
                FinishedStageView()

            case .erroredOut:
                ErroredOutStageView()
            }
        }
        .padding()
        .fixedSize()
        .allAnimationsDisabled()
    }
}
