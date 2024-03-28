//
//  Updating Package Tracker.swift
//  Cork
//
//  Created by David Bureš on 17.10.2023.
//

import SwiftUI

struct UpdatingPackageTrackerStateView: View
{

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker
    @EnvironmentObject var updateProgressTracker: UpdateProgressTracker
    @EnvironmentObject var brewData: BrewDataStorage

    @Binding var packageUpdatingStage: PackageUpdatingStage

    var body: some View
    {
        Text("update-packages.updating.updating-outdated-package")
            .task(priority: .userInitiated)
            {
                do
                {
                    outdatedPackageTracker.outdatedPackages = try await getListOfUpgradeablePackages(brewData: brewData)

                    updateProgressTracker.updateProgress = 10

                    if updateProgressTracker.errors.isEmpty
                    {
                        packageUpdatingStage = .finished
                    }
                    else
                    {
                        packageUpdatingStage = .erroredOut
                    }
                }
                catch let outdatedPackageRetrievalError as OutdatedPackageRetrievalError
                {
                    switch outdatedPackageRetrievalError
                    {
                    case .homeNotSet:
                        appState.showAlert(errorToShow: .homePathNotSet)
                    case .otherError:
                            AppConstants.logger.error("Something went wrong")
                    }
                }
                catch
                {
                    AppConstants.logger.error("IDK what just happened")
                }
            }
    }
}
