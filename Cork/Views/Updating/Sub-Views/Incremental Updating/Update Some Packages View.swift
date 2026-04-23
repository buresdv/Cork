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
        VStack(alignment: .center)
        {
            ProgressView(updateProgressTracker.updateProgress)
        }
        .toolbar
        {
            ToolbarItem(placement: .automatic)
            {
                if let packageBeingUpdated = updateProgressTracker.packageBeingCurrentlyUpdated
                {
                    Text("update-packages.incremental.update-in-progress-\(packageBeingUpdated.package.name(withPrecision: .precise))")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .task
        {
            var consolidatedUpdateResults: [SinglePackageUpdatingResult] = .init()

            for packageToUpdate in packagesToUpdate
            {
                
                let packageProgress: Progress = Progress(
                    totalUnitCount: 3,
                    parent: updateProgressTracker.updateProgress,
                    pendingUnitCount: 1
                )
                
                packageProgress.completedUnitCount = 1

                updateProgressTracker.packageBeingCurrentlyUpdated = packageToUpdate
                
                packageProgress.completedUnitCount = 2

                let updatingResult: SinglePackageUpdatingResult = await outdatedPackagesTracker.updateSinglePackage(
                    packageToUpdate: packageToUpdate
                )

                consolidatedUpdateResults.append(updatingResult)
                
                packageProgress.completedUnitCount = 3
            }
            
            /// Extract only the failed updates from the results array
            let failedUpdates = consolidatedUpdateResults.compactMap
            { result -> OutdatedPackagesTracker.IndividualPackageUpdatingError? in
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
