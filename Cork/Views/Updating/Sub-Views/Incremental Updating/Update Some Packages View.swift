//
//  Update Some Packages View.swift
//  Cork
//
//  Created by David Bureš on 05.04.2023.
//

import CorkModels
import CorkShared
import CorkTerminalFunctions
import FactoryKit
import SwiftUI
import BetterProgress

struct UpdateSomePackagesView: View
{
    @Injected(\.appConstants) var appConstants: AppConstants
    
    @InjectedObservable(\.appState) var appState: AppState
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker
    @InjectedObservable(\.outdatedPackagesTracker) var outdatedPackagesTracker: OutdatedPackagesTracker
    @Environment(UpdateProgressTracker.self) var updateProgressTracker: UpdateProgressTracker

    @State private var packageUpdatingErrors: [String] = .init()

    let packagesToUpdate: [OutdatedPackage]

    var numberOfPackagesToUpdate: Int
    {
        packagesToUpdate.count
    }

    var body: some View
    {
        VStack(alignment: .leading)
        {
            ProgressView(updateProgressTracker.updateProgress)
            
            updateProgressTracker.streamedOutputsDisplay
        }
        .frame(maxWidth: .infinity)
        .task
        {
            var consolidatedUpdateResults: [SinglePackageUpdatingResult] = .init()
            
            /// Keep track of which package in line is being updated - So we can do "updating package 1 of 3"
            var numberInLineOfPackageBeingCurrentlyUpdated: Int = 0

            for packageToUpdate in packagesToUpdate
            {
                numberInLineOfPackageBeingCurrentlyUpdated += 1
                
                let numberOfItemsInPackageProgress: Int = 3
                
                let packageProgress: Progress = .init(
                    parent: updateProgressTracker.updateProgress,
                    percentageOfParentToTakeUp: Double(100/packagesToUpdate.count),
                    totalItemsOfThisProgress: numberOfItemsInPackageProgress
                )

                updateProgressTracker.packageBeingCurrentlyUpdated = packageToUpdate
                
                updateProgressTracker.updateProgress.setText(to: .aboveBar(String(localized:"update-packages.incremental.package-count.\(numberInLineOfPackageBeingCurrentlyUpdated)-of-\(packagesToUpdate.count)")))
                
                if let packageBeingUpdated = updateProgressTracker.packageBeingCurrentlyUpdated
                {
                    updateProgressTracker.updateProgress.setText(to: .belowBar(String(localized: "update-packages.incremental.update-in-progress-\(packageBeingUpdated.package.name(withPrecision: .inlineFormatted))")))
                }
                else
                {
                    updateProgressTracker.updateProgress.setText(to: .belowBar(String(localized: "update-packages.incremental.update-in-progress.unknown-package")))
                }
                
                packageProgress.increment(bySetNumber: 1)

                let packageInstallStageProgress: Progress = .init(
                    parent: packageProgress,
                    percentageOfParentToTakeUp: 35,
                    totalItemsOfThisProgress: 10
                )
                
                let updatingResult: SinglePackageUpdatingResult = await outdatedPackagesTracker.updateSinglePackage(
                    packageToUpdate: packageToUpdate,
                    updateProgressTracker: updateProgressTracker,
                    updateStageProgress: packageInstallStageProgress
                )

                consolidatedUpdateResults.append(updatingResult)
                
                packageProgress.set(toPercentage: 100)
            }
            
            /// Extract only the failed updates from the results array
            let failedUpdates: [UpdateProgressTracker.IndividualPackageUpdatingError] = consolidatedUpdateResults.compactMap
            { result -> UpdateProgressTracker.IndividualPackageUpdatingError? in
                guard case .failure(let error) = result else { return nil }
                return error
            }

            if failedUpdates.isEmpty
            {
                updateProgressTracker.updatingState = .finished
            }
            else
            {
                updateProgressTracker.updatingState = .erroredOut(results: failedUpdates)
            }
        }
    }
}
