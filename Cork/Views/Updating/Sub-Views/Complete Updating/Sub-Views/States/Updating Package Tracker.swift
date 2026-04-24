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
import FactoryKit

/*
struct UpdatingPackageTrackerStateView: View
{
    @Default(.includeGreedyOutdatedPackages) var includeGreedyOutdatedPackages: Bool
    
    @InjectedObservable(\.appState) var appState: AppState
    @InjectedObservable(\.outdatedPackagesTracker) var outdatedPackagesTracker: OutdatedPackagesTracker
    @Environment(UpdateProgressTracker.self) var updateProgressTracker: UpdateProgressTracker
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker

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
                    
                    updateProgressTracker.updateProgress.completedUnitCount = Int64(outdatedPackagesTracker.packagesMarkedForUpdating.count)

                    if updateProgressTracker.errors.isEmpty
                    {
                        updateProgressTracker.updatingState = .finished
                    }
                    else
                    {
                        updateProgressTracker.updatingState = .erroredOut(results: <#T##[OutdatedPackagesTracker.IndividualPackageUpdatingError]#>)
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
*/
