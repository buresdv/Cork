//
//  Update Some Packages View.swift
//  Cork
//
//  Created by David Bureš on 05.04.2023.
//

import SwiftUI
import CorkShared

struct UpdateSomePackagesView: View
{
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker

    @State private var packageUpdatingStage: PackageUpdatingStage = .updating
    @State private var packageBeingCurrentlyUpdated: BrewPackage = .init(name: "", type: .formula, installedOn: nil, versions: [], url: nil)
    @State private var updateProgress: Double = 0.0

    @State private var packageUpdatingErrors: [String] = .init()

    var selectedPackages: [OutdatedPackage]
    {
        return outdatedPackageTracker.displayableOutdatedPackages.filter { $0.isMarkedForUpdating }
    }

    var body: some View
    {
        VStack(alignment: .leading, spacing: 10)
        {
            switch packageUpdatingStage
            {
            case .updating:
                ProgressView(value: updateProgress, total: Double(selectedPackages.count))
                {
                    Text("update-packages.incremental.update-in-progress-\(packageBeingCurrentlyUpdated.name)")
                }
                .frame(width: 200)
                .task
                {
                    for (index, outdatedPackage) in selectedPackages.enumerated()
                    {
                        packageBeingCurrentlyUpdated = outdatedPackage.package

                        var updateCommandArguments: [String] = .init()

                        if packageBeingCurrentlyUpdated.type == .formula
                        {
                            updateCommandArguments = ["reinstall", packageBeingCurrentlyUpdated.name]
                        }
                        else
                        {
                            updateCommandArguments = ["reinstall", "--cask", packageBeingCurrentlyUpdated.name]
                        }

                        AppConstants.shared.logger.info("Update command: \(updateCommandArguments)")

                        for await output in shell(AppConstants.shared.brewExecutablePath, updateCommandArguments)
                        {
                            switch output
                            {
                            case .standardOutput(let outputLine):
                                AppConstants.shared.logger.info("Individual package updating output: \(outputLine)")
                                updateProgress = updateProgress + (Double(selectedPackages.count) / 100)

                            case .standardError(let errorLine):
                                AppConstants.shared.logger.info("Individual package updating error: \(errorLine)")
                                updateProgress = updateProgress + (Double(selectedPackages.count) / 100)

                                if !errorLine.contains("The post-install step did not complete successfully")
                                {
                                    packageUpdatingErrors.append("\(packageBeingCurrentlyUpdated.name): \(errorLine)")
                                }
                            }
                        }

                        updateProgress = Double(index) + 1
                        AppConstants.shared.logger.info("Update progress index: \(updateProgress)")
                    }

                    if !packageUpdatingErrors.isEmpty
                    {
                        packageUpdatingStage = .erroredOut(packagesRequireSudo: packageUpdatingErrors.contains("a terminal is required to read the password"))
                    }
                    else
                    {
                        packageUpdatingStage = .finished
                    }

                    do
                    {
                        AppConstants.shared.logger.debug("Will synchronize outdated packages")
                        try await outdatedPackageTracker.getOutdatedPackages(brewData: brewData)
                    }
                    catch let packageSynchronizationError
                    {
                        AppConstants.shared.logger.error("Could not synchronize packages: \(packageSynchronizationError, privacy: .public)")
                        appState.showAlert(errorToShow: .couldNotSynchronizePackages(error: packageSynchronizationError.localizedDescription))
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
    }
}
