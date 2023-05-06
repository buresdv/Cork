//
//  Update Some Packages View.swift
//  Cork
//
//  Created by David Bureš on 05.04.2023.
//

import SwiftUI

struct UpdateSomePackagesView: View
{
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker

    @Binding var isShowingSheet: Bool

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

                        print("Update command: \(updateCommandArguments)")

                        for await output in shell(AppConstants.brewExecutablePath.absoluteString, updateCommandArguments)
                        {
                            switch output
                            {
                            case let .standardOutput(outputLine):
                                print("Individual package updating output: \(outputLine)")
                                updateProgress = updateProgress + (Double(selectedPackages.count) / 100)

                            case let .standardError(errorLine):
                                print("Individual package updating error: \(errorLine)")
                                updateProgress = updateProgress + (Double(selectedPackages.count) / 100)

                                    if !errorLine.contains("The post-install step did not complete successfully")
                                    {
                                        packageUpdatingErrors.append("\(packageBeingCurrentlyUpdated.name): \(errorLine)")
                                    }
                            }
                        }

                        updateProgress = Double(index) + 1
                        print("Update progress index: \(updateProgress)")
                    }

                    if !packageUpdatingErrors.isEmpty
                    {
                        packageUpdatingStage = .erroredOut
                    }
                    else
                    {
                        packageUpdatingStage = .finished
                    }
                    
                    outdatedPackageTracker.outdatedPackages = removeUpdatedPackages(outdatedPackageTracker: outdatedPackageTracker, namesOfUpdatedPackages: selectedPackages.map(\.package.name))
                }
            case .finished:
                DisappearableSheet(isShowingSheet: $isShowingSheet)
                {
                    ComplexWithIcon(systemName: "checkmark.seal")
                    {
                        SheetWithTitle(title: "update-packages.incremental.finished")
                        {
                            Text("update-packages.finished.description")
                        }
                    }
                }
                .onAppear
                    {
                        
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
                            DismissSheetButton(isShowingSheet: $isShowingSheet, customButtonText: "action.close")
                        }
                    }
                    .fixedSize()
                    .onAppear
                    {
                        print("Update errors: \(packageUpdatingErrors)")
                    }
                }

            case .noUpdatesAvailable:
                Text("update-packages.incremental.impossible-case")
            }
        }
        .padding()
    }
    
    func removeUpdatedPackages(outdatedPackageTracker: OutdatedPackageTracker, namesOfUpdatedPackages: [String]) -> [OutdatedPackage]
    {
        for updatedPackageName in namesOfUpdatedPackages
        {
            outdatedPackageTracker.outdatedPackages.removeAll(where: { $0.package.name == updatedPackageName })
        }
        
        return outdatedPackageTracker.outdatedPackages
    }
}
