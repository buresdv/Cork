//
//  Updating Package Tracker.swift
//  Cork
//
//  Created by David Bureš on 17.10.2023.
//

import SwiftUI
import CorkShared
import Defaults
import CorkModels

struct UpdatingPackageTrackerStateView: View
{
    @Default(.includeGreedyOutdatedPackages) var includeGreedyOutdatedPackages: Bool
    
    @Environment(AppState.self) var appState: AppState
    @Environment(OutdatedPackagesTracker.self) var outdatedPackagesTracker: OutdatedPackagesTracker
    @Environment(UpdateProgressTracker.self) var updateProgressTracker: UpdateProgressTracker
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker

    @Binding var packageUpdatingStage: PackageUpdatingStage

    var body: some View
    {
        Text("update-packages.updating.updating-outdated-package")
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .task
            {
                do
                {
                    try await outdatedPackagesTracker.getOutdatedPackages(brewPackagesTracker: brewPackagesTracker)
                    
                    updateProgressTracker.updateProgress = 10

                    if updateProgressTracker.errors.isEmpty
                    {
                        packageUpdatingStage = .finished
                    }
                    else
                    {
                        if updateProgressTracker.errors.contains("a terminal is required to read the password")
                        {
                            packageUpdatingStage = .erroredOut(packagesRequireSudo: true)
                        }
                        else
                        {
                            packageUpdatingStage = .erroredOut(packagesRequireSudo: false)
                        }
                    }
                }
                catch let outdatedPackageRetrievalError as OutdatedPackageRetrievalError
                {
                    switch outdatedPackageRetrievalError
                    {
                    case .homeNotSet:
                        appState.showAlert(errorToShow: .homePathNotSet)
                    case .couldNotDecodeCommandOutput(let decodingError):
                        // TODO: Swallow the error for now so that I don't have to bother the translators. Add alert later
                        AppConstants.shared.logger.error("Could not decode outdated package command output: \(decodingError)")
                        appState.showAlert(errorToShow: .receivedInvalidResponseFromBrew)
                    case .otherError:
                        AppConstants.shared.logger.error("Something went wrong")
                    }
                }
                catch
                {
                    AppConstants.shared.logger.error("IDK what just happened")
                }
            }
    }
}
