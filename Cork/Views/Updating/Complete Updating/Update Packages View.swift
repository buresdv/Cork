//
//  Update Packages.swift
//  Cork
//
//  Created by David Bureš on 09.03.2023.
//

import SwiftUI

struct UpdatePackagesView: View
{
    @Binding var isShowingSheet: Bool

    @State var packageUpdatingStage: PackageUpdatingStage = .updating
    @State var packageUpdatingStep: PackageUpdatingProcessSteps = .ready

    @State var updateAvailability: PackageUpdateAvailability = .updatesAvailable

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var updateProgressTracker: UpdateProgressTracker
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker
    @EnvironmentObject var brewData: BrewDataStorage

    @StateObject var updateProcessDetailsStage: UpdatingProcessDetails = .init()

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
                            updateAvailability: $updateAvailability
                        )

                    case .updatingPackages:
                        UpdatingPackagesStateView(
                            updateProcessDetailsStage: updateProcessDetailsStage,
                            packageUpdatingStep: $packageUpdatingStep
                        )

                    case .updatingOutdatedPackageTracker:
                        UpdatingPackagesStateView(
                            updateProcessDetailsStage: updateProcessDetailsStage,
                            packageUpdatingStep: $packageUpdatingStep
                        )

                    case .finished:
                        UpdatingFinishedStateView(
                            packageUpdatingStep: $packageUpdatingStep
                        )
                    }
                }
                .frame(width: 200)
                .fixedSize()

            case .noUpdatesAvailable:
                NoUpdatesAvailableStageView(
                    isShowingSheet: $isShowingSheet
                )

            case .finished:
                FinishedStageView(isShowingSheet: $isShowingSheet)

            case .erroredOut:
                ErroredOutStageView()
            }
        }
        .padding()
    }
}
