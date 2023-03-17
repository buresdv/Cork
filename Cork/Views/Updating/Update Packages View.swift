//
//  Update Packages.swift
//  Cork
//
//  Created by David Bureš on 09.03.2023.
//

import SwiftUI

struct UpdatePackagesView: View
{
    @Binding var isShowingSheet: Bool

    @State var packageUpdatingStage: PackageUpdatingStage = .updating
    @State var packageUpdatingStep: PackageUpdatingProcessSteps = .ready
    
    @State var updateAvailability: PackageUpdateAvailability = .updatesAvailable

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var updateProgressTracker: UpdateProgressTracker
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker

    var body: some View
    {
        VStack(alignment: .leading, spacing: 10)
        {
            switch packageUpdatingStage
            {
            case .updating:
                ProgressView(value: updateProgressTracker.updateProgress, total: 10)
                {
                    switch packageUpdatingStep
                    {
                    case .ready:
                        Text("Ready")
                            .onAppear
                            {
                                packageUpdatingStep = .checkingForUpdates
                            }

                    case .checkingForUpdates:
                        Text("Fetching updates...")
                            .onAppear
                            {
                                Task(priority: .userInitiated)
                                {
                                    updateAvailability = await updatePackages(updateProgressTracker, appState: appState)

                                    print("Update availability result: \(updateAvailability)")

                                    if updateAvailability == .noUpdatesAvailable
                                    {
                                        print("Outside update function: No updates available")
                                        packageUpdatingStage = .noUpdatesAvailable
                                    }
                                    else
                                    {
                                        print("Outside update function: Updates available")
                                        packageUpdatingStep = .updatingPackages
                                    }
                                }
                            }

                    case .updatingPackages:
                        Text("Updating packages...")
                            .onAppear
                            {
                                Task(priority: .userInitiated)
                                {
                                    await upgradePackages(updateProgressTracker, appState: appState, outdatedPackageTracker: outdatedPackageTracker)
                                    
                                    packageUpdatingStep = .updatingOutdatedPackageTracker
                                }
                            }

                    case .updatingOutdatedPackageTracker:
                        Text("Updating package tracker...")
                            .onAppear
                            {
                                Task(priority: .userInitiated) {
                                    outdatedPackageTracker.outdatedPackageNames = await getListOfUpgradeablePackages()
                                    
                                    if updateProgressTracker.errors.isEmpty
                                    {
                                        packageUpdatingStage = .finished
                                    }
                                    else
                                    {
                                        packageUpdatingStage = .erroredOut
                                    }
                                }
                            }

                    case .finished:
                        Text("Done")
                            .onAppear
                            {
                                packageUpdatingStep = .finished
                            }
                    }
                }
                .fixedSize()

            case .noUpdatesAvailable:
                DisappearableSheet(isShowingSheet: $isShowingSheet)
                {
                    ComplexWithIcon(systemName: "checkmark.seal")
                    {
                        HeadlineWithSubheadline(headline: "No updates available", subheadline: "You're all up to date", alignment: .leading)
                            .fixedSize()
                    }
                }

            case .finished:
                DisappearableSheet(isShowingSheet: $isShowingSheet)
                {
                    ComplexWithIcon(systemName: "checkmark.seal")
                    {
                        HeadlineWithSubheadline(headline: "Sucessfully upgraded packages", subheadline: "There were no errors", alignment: .leading)
                            .fixedSize()
                    }
                }

            case .erroredOut:
                ComplexWithIcon(systemName: "xmark.seal")
                {
                    VStack(alignment: .leading, spacing: 5)
                    {
                        HeadlineWithSubheadline(headline: "Packages updated with errors", subheadline: "There were some errors during updating.\nCheck below for more information", alignment: .leading)
                        List
                        {
                            ForEach(updateProgressTracker.errors, id: \.self)
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
                            DismissSheetButton(isShowingSheet: $appState.isShowingUpdateSheet, customButtonText: "Close")
                        }
                    }
                    .fixedSize()
                    .onAppear
                    {
                        print("Update errors: \(updateProgressTracker.errors)")
                    }
                }
            }
        }
        .padding()
    }
}
