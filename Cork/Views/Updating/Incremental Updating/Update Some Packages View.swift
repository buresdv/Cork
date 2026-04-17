//
//  Update Some Packages View.swift
//  Cork
//
//  Created by David Bureš on 05.04.2023.
//

import SwiftUI
import CorkShared
import CorkModels
import CorkTerminalFunctions
import FactoryKit

struct UpdateSomePackagesView: View
{
    @InjectedObservable(\.appState) var appState: AppState
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker
    @Environment(OutdatedPackagesTracker.self) var outdatedPackagesTracker: OutdatedPackagesTracker

    @State private var packageUpdatingStage: PackageUpdatingStage = .updating
    @State private var packageBeingCurrentlyUpdated: BrewPackage = .init(rawName: "", type: .formula, installedOn: nil, versions: [], url: nil, sizeInBytes: nil, downloadCount: nil)
    
    @State private var updateProgressValue: Progress?

    @State private var packageUpdatingErrors: [String] = .init()

    let packagesToUpdate: [OutdatedPackage]
    
    var numberOfPackagesToUpdate: Int
    {
        packagesToUpdate.count
    }

    var body: some View
    {
        VStack(alignment: .leading, spacing: 10)
        {
            switch packageUpdatingStage
            {
            case .updating:
                if let updateProgressValue
                {
                    VStack(alignment: .center)
                    {
                        ProgressView(updateProgressValue)
                        
                        Text("update-packages.incremental.update-in-progress-\(packageBeingCurrentlyUpdated.name(withPrecision: .precise))")
                    }
                    .frame(width: 200)
                    .task
                    {
                        for packageToUpdate in packagesToUpdate
                        {
                            updateProgressTracker.updateSinglePackage(packageToUpdate: packageToUpdate)
                        }
                    }
                }

            case .finished:
                DisappearableSheet
                {
                    ComplexWithIcon(systemName: "checkmark.seal")
                    {
                        SheetWithTitle(title: "update-packages.incremental.finished")
                        {
                            Text("update-packages.finished.description")
                        }
                    }
                }

            case .erroredOut(let packagesRequireSudoToUpdate):
                ErroredOutStageView(sudoRequiredForUpdate: packagesRequireSudoToUpdate)

            case .noUpdatesAvailable:
                Text("update-packages.incremental.impossible-case")
            }
        }
        .padding()
        .onAppear
        {
            self.updateProgressValue = .init(totalUnitCount: Int64(numberOfPackagesToUpdate))
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
