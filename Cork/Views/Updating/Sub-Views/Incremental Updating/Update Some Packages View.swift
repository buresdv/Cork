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
    @InjectedObservable(\.appState) var appState: AppState
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker
    @Environment(OutdatedPackagesTracker.self) var outdatedPackagesTracker: OutdatedPackagesTracker
    @Environment(UpdateProgressTracker.self) var updateProgressTracker: UpdateProgressTracker

    @State private var packageBeingCurrentlyUpdated: BrewPackage?

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
                if let updateProgress = updateProgressTracker.updateProgress
                {
                    ProgressView(updateProgress)
                }
                
                if let packageBeingUpdated = packageBeingCurrentlyUpdated
                {
                    Text("update-packages.incremental.update-in-progress-\(packageBeingUpdated.name(withPrecision: .precise))")
                }

            }
            .frame(width: 200)
            .task
            {
                var consolidatedUpdateResults: [SinglePackageUpdatingResult] = .init()

                for packageToUpdate in packagesToUpdate
                {
                    packageBeingCurrentlyUpdated = packageToUpdate.package

                    let updatingResult: SinglePackageUpdatingResult = outdatedPackagesTracker.updateSinglePackage(
                        packageToUpdate: packageToUpdate
                    )

                    consolidatedUpdateResults.append(updatingResult)

                    /// Extract only the failed updates from the results array
                    let failedUpdates = consolidatedUpdateResults.compactMap
                    { result -> OutdatedPackagesTracker.IndividualPackageUpdatingError? in
                        guard case .failure(let error) = result else { return nil }
                        return error
                    }

                    if failedUpdates.isEmpty
                    {
                        updateProgressTracker.packageUpdatingState = .finished
                    }
                    else
                    {
                        updateProgressTracker.packageUpdatingState = .erroredOut(results: failedUpdates)
                    }
                }
            }
            .padding()
            .onAppear
            {
                updateProgressTracker.updateProgress = .init(totalUnitCount: Int64(numberOfPackagesToUpdate))
            }
            .onDisappear
            {
                Task
                {
                    do
                    {
                        outdatedPackagesTracker.isCheckingForPackageUpdates = true

                        defer
                        {
                            outdatedPackagesTracker.isCheckingForPackageUpdates = false
                        }

                        AppConstants.shared.logger.debug("Will synchronize outdated packages")
                        try await outdatedPackagesTracker.getOutdatedPackages(brewPackagesTracker: brewPackagesTracker)
                    }
                    catch let packageSynchronizationError
                    {
                        AppConstants.shared.logger.error("Could not synchronize packages: \(packageSynchronizationError, privacy: .public)")

                        appState.showAlert(errorToShow: .couldNotSynchronizePackages(error: packageSynchronizationError.localizedDescription))
                    }
                }
            }
    }
}
