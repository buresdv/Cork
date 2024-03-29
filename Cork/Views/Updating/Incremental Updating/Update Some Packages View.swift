//
//  Update Some Packages View.swift
//  Cork
//
//  Created by David Bureš on 05.04.2023.
//

import SwiftUI


struct UpdateSomePackagesView: View
{
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker

    @State private var packageUpdatingStage: PackageUpdatingStage = .updating
    @State private var packageBeingCurrentlyUpdated: BrewPackage = .init(name: "", isCask: false, installedOn: nil, versions: [], sizeInBytes: nil)
    @State private var updateProgress: Double = 0.0

    @State private var packageUpdatingErrors: [String] = .init()

    var selectedPackages: [OutdatedPackage]
    {
        return outdatedPackageTracker.outdatedPackages.filter { $0.isMarkedForUpdating }
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
                .task(priority: .userInitiated)
                {
                    for (index, outdatedPackage) in selectedPackages.enumerated()
                    {
                        packageBeingCurrentlyUpdated = outdatedPackage.package

                        var updateCommandArguments: [String] = .init()

                        if !packageBeingCurrentlyUpdated.isCask
                        {
                            updateCommandArguments = ["reinstall", packageBeingCurrentlyUpdated.name]
                        }
                        else
                        {
                            updateCommandArguments = ["reinstall", "--cask", packageBeingCurrentlyUpdated.name]
                        }

                        AppConstants.logger.info("Update command: \(updateCommandArguments)")

                        for await output in shell(AppConstants.brewExecutablePath, updateCommandArguments)
                        {
                            switch output
                            {
                            case let .standardOutput(outputLine):
                                    AppConstants.logger.info("Individual package updating output: \(outputLine)")
                                updateProgress = updateProgress + (Double(selectedPackages.count) / 100)

                            case let .standardError(errorLine):
                                    AppConstants.logger.info("Individual package updating error: \(errorLine)")
                                updateProgress = updateProgress + (Double(selectedPackages.count) / 100)

                                    if !errorLine.contains("The post-install step did not complete successfully")
                                    {
                                        packageUpdatingErrors.append("\(packageBeingCurrentlyUpdated.name): \(errorLine)")
                                    }
                            }
                        }

                        updateProgress = Double(index) + 1
                        AppConstants.logger.info("Update progress index: \(updateProgress)")
                    }

                    if !packageUpdatingErrors.isEmpty
                    {
                        packageUpdatingStage = .erroredOut
                    }
                    else
                    {
                        packageUpdatingStage = .finished
                    }
                    
                    do
                    {
                        outdatedPackageTracker.outdatedPackages = try await getListOfUpgradeablePackages(brewData: brewData)
                    }
                    catch let packageSynchronizationError
                    {
                        AppConstants.logger.error("Could not synchronize packages: \(packageSynchronizationError, privacy: .public)")
                        appState.showAlert(errorToShow: .couldNotSynchronizePackages)
                    }
                    
                    /// Old way of synchronizing outdated packages that sometimes didn't synchronize properly
                    // outdatedPackageTracker.outdatedPackages = removeUpdatedPackages(outdatedPackageTracker: outdatedPackageTracker, namesOfUpdatedPackages: selectedPackages.map(\.package.name))
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

            case .erroredOut:
                ComplexWithIcon(systemName: "checkmark.seal")
                {
                    VStack(alignment: .leading, spacing: 5)
                    {
                        HeadlineWithSubheadline(
                            headline: "update-packages.error",
                            subheadline: "update-packages.error.description",
                            alignment: .leading
                        )
                        List
                        {
                            ForEach(packageUpdatingErrors, id: \.self)
                            { error in
                                HStack(alignment: .firstTextBaseline, spacing: 5)
                                {
                                    Text("⚠️")
                                    Text(error)
                                }
                            }
                        }
                        .listStyle(.bordered(alternatesRowBackgrounds: false))
                        .frame(height: 100, alignment: .leading)
                        HStack
                        {
                            Spacer()
                            DismissSheetButton(customButtonText: "action.close")
                        }
                    }
                    .fixedSize()
                    .onAppear
                    {
                        AppConstants.logger.error("Update errors: \(packageUpdatingErrors, privacy: .public)")
                    }
                }

            case .noUpdatesAvailable:
                Text("update-packages.incremental.impossible-case")
            }
        }
        .padding()
    }
    
    func removeUpdatedPackages(outdatedPackageTracker: OutdatedPackageTracker, namesOfUpdatedPackages: [String]) -> Set<OutdatedPackage>
    {
        outdatedPackageTracker.outdatedPackages = outdatedPackageTracker.outdatedPackages.filter { outdatedPackage in
            return !namesOfUpdatedPackages.contains(outdatedPackage.package.name)
        }
        
        return outdatedPackageTracker.outdatedPackages
    }
}
