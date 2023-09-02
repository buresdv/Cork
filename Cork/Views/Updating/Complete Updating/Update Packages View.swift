//
//  Update Packages.swift
//  Cork
//
//  Created by David Bureš on 09.03.2023.
//

import SwiftUI

struct UpdatePackagesView: View
{
    @AppStorage("notifyAboutPackageUpgradeResults") var notifyAboutPackageUpgradeResults: Bool = false

    @Binding var isShowingSheet: Bool

    @State var packageUpdatingStage: PackageUpdatingStage = .updating
    @State var packageUpdatingStep: PackageUpdatingProcessSteps = .ready

    @State var updateAvailability: PackageUpdateAvailability = .updatesAvailable

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var updateProgressTracker: UpdateProgressTracker
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker
    @EnvironmentObject var brewData: BrewDataStorage

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
                        Text("update-packages.updating.ready")
                            .onAppear
                            {
                                updateProgressTracker.updateProgress = 0
                                packageUpdatingStep = .checkingForUpdates
                            }

                    case .checkingForUpdates:
                        Text("update-packages.updating.checking")
                            .onAppear
                            {
                                Task(priority: .userInitiated)
                                {
                                    updateAvailability = await refreshPackages(updateProgressTracker, outdatedPackageTracker: outdatedPackageTracker)

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
                        Text("update-packages.updating.updating")
                            .onAppear
                            {
                                Task(priority: .userInitiated)
                                {
                                    await updatePackages(updateProgressTracker, appState: appState, outdatedPackageTracker: outdatedPackageTracker)

                                    packageUpdatingStep = .updatingOutdatedPackageTracker
                                }
                            }

                    case .updatingOutdatedPackageTracker:
                        Text("update-packages.updating.updating-outdated-package")
                            .onAppear
                            {
                                Task(priority: .userInitiated)
                                {
                                    do
                                    {
                                        outdatedPackageTracker.outdatedPackages = try await getListOfUpgradeablePackages(brewData: brewData)

                                        updateProgressTracker.updateProgress = 10

                                        if updateProgressTracker.errors.isEmpty
                                        {
                                            packageUpdatingStage = .finished
                                        }
                                        else
                                        {
                                            packageUpdatingStage = .erroredOut
                                        }
                                    }
                                    catch let outdatedPackageRetrievalError as OutdatedPackageRetrievalError
                                    {
                                        switch outdatedPackageRetrievalError
                                        {
                                        case .homeNotSet:
                                            appState.fatalAlertType = .homePathNotSet
                                            appState.isShowingFatalError = true
                                        case .otherError:
                                            print("Something went wrong")
                                        }
                                    }
                                }
                            }

                    case .finished:
                        Text("update-packages.updating.finished")
                            .onAppear
                            {
                                packageUpdatingStep = .finished
                            }
                    }
                }
                .frame(width: 200)
                .fixedSize()

            case .noUpdatesAvailable:
                DisappearableSheet(isShowingSheet: $isShowingSheet)
                {
                    ComplexWithIcon(systemName: "checkmark.seal")
                    {
                        HeadlineWithSubheadline(
                            headline: "update-packages.no-updates",
                            subheadline: "update-packages.no-updates.description",
                            alignment: .leading
                        )
                        .fixedSize()
                    }
                }
                .onAppear
                {
                    if notifyAboutPackageUpgradeResults
                    {
                        sendNotification(title: String(localized: "update-packages.no-updates"))
                    }
                }

            case .finished:
                DisappearableSheet(isShowingSheet: $isShowingSheet)
                {
                    ComplexWithIcon(systemName: "checkmark.seal")
                    {
                        HeadlineWithSubheadline(
                            headline: "update-packages.finished",
                            subheadline: "update-packages.finished.description",
                            alignment: .leading
                        )
                        .fixedSize()
                    }
                }
                .onAppear
                {
                    if notifyAboutPackageUpgradeResults
                    {
                        sendNotification(title: String(localized:"notification.upgrade-finished.success"))
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
                            DismissSheetButton(isShowingSheet: $appState.isShowingUpdateSheet, customButtonText: "action.close")
                        }
                    }
                    .fixedSize()
                    .onAppear
                    {
                        print("Update errors: \(updateProgressTracker.errors)")
                    }
                }
                .onAppear
                {
                    if notifyAboutPackageUpgradeResults
                    {
                        sendNotification(title: String(localized: "notification.upgrade-finished.success"), body: String(localized:"notification.upgrade-finished.success.some-errors"))
                    }
                }
            }
        }
        .padding()
    }
}
