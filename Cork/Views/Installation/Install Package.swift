//
//  Add Package.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import ButtonKit
import CorkModels
import CorkNotifications
import CorkShared
import Defaults
import FactoryKit
import SwiftUI

typealias PackageInstallationProcessStepTracker = InstallPackageView.PackageInstallationProcessStepTracker

struct InstallPackageView: View
{
    @Observable
    final class PackageInstallationProcessStepTracker
    {
        private(set) var currentStep: PackageInstallationProcessSteps

        init()
        {
            self.currentStep = .ready
        }

        func advanceStep(to newStep: PackageInstallationProcessSteps)
        {
            self.currentStep = newStep
        }
    }

    @Environment(\.dismiss) var dismiss: DismissAction

    @State private var packageRequested: String = ""

    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker
    @InjectedObservable(\.appState) var appState: AppState

    @Environment(CachedDownloadsTracker.self) var cachedDownloadsTracker: CachedDownloadsTracker

    @State var packageInstallTrackingNumber: Float = 0

    @FocusState var isSearchFieldFocused: Bool

    @State private var packageInstallationProcessStepTracker: PackageInstallationProcessStepTracker = .init()

    @State private var installationProgressTracker: InstallationProgressTracker?

    @Default(.notifyAboutPackageInstallationResults) var notifyAboutPackageInstallationResults: Bool

    var sheetTitle: LocalizedStringKey
    {
        return "add-package.title"
    }

    var body: some View
    {
        NavigationStack
        {
            SheetTemplate(isShowingTitle: true)
            {
                Group
                {
                    switch packageInstallationProcessStepTracker.currentStep
                    {
                    case .ready:
                        InstallationInitialView()
                    case .searching(let forSearchString):
                        InstallationSearchingView(
                            packageRequested: forSearchString
                        )
                    case .presentingSearchResults(let forSearchString, let foundFormulae, let foundCasks):
                        PresentingSearchResultsView(
                            oldSearchString: forSearchString,
                            foundFormulae: foundFormulae,
                            foundCasks: foundCasks
                        )
                    case .installing(let package):
                        // TODO: Fix this hideous shit
                        /// This is here because I need the binding to be optional here, but not optional in the child
                        let trackerBinding: Binding<InstallationProgressTracker> = .init(
                            get: {
                                if let existingTracker = installationProgressTracker
                                {
                                    return existingTracker
                                }
                                else
                                {
                                    let newTracker: InstallationProgressTracker = .init(packageToInstall: package)
                                    installationProgressTracker = newTracker // How about this line undefines my behavior
                                    return newTracker
                                }
                            },
                            set: { installationProgressTracker = $0 }
                        )
                        InstallingPackageView(packageToInstall: package, installationProgressTracker: trackerBinding)
                    case .finished:
                        InstallationFinishedSuccessfullyView()
                    case .unexpectedTerminalOutput(let unexpectedOutputType):
                        // TODO: Implement the unexpected output views
                        switch unexpectedOutputType
                        {
                        case .containedErrors(let rawOutputThatContainsErrors):
                            EmptyView()
                        case .didNotContainErrors(let rawOutputThatDidNotContainErrors):
                            EmptyView()
                        }
                    case .erroredOut(let package, let withError):
                        ErroredOutView(
                            error: withError,
                            packageThatWasBeingInstalled: package
                        )
                    }
                }
                .navigationTitle(sheetTitle)
                .toolbar
                {
                    if packageInstallationProcessStepTracker.currentStep.isDismissable
                    {
                        ToolbarItem(placement: .cancellationAction)
                        {
                            AsyncButton
                            {
                                dismiss()
                                installationProgressTracker?.cancel()

                                do
                                {
                                    try await brewPackagesTracker.synchronizeInstalledPackages(cachedDownloadsTracker: cachedDownloadsTracker)
                                }
                                catch let synchronizationError
                                {
                                    appState.showAlert(errorToShow: .couldNotSynchronizePackages(error: synchronizationError.localizedDescription))
                                }
                            } label: {
                                if let customDismissText = packageInstallationProcessStepTracker.currentStep.customDismissButtonText
                                {
                                    Text(customDismissText)
                                }
                                else
                                {
                                    Text("action.cancel")
                                }
                            }
                            .keyboardShortcut(.cancelAction)
                            .disabledWhenLoading()
                        }
                    }
                }
            }
        }
        .environment(packageInstallationProcessStepTracker)
        .onDisappear
        {
            cachedDownloadsTracker.assignPackageTypeToCachedDownloads(brewPackagesTracker: brewPackagesTracker)
            Task
            {
                try? await brewPackagesTracker.synchronizeInstalledPackages(cachedDownloadsTracker: cachedDownloadsTracker)
            }
        }
    }
}
