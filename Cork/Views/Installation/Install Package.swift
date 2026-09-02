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

    @InjectedObservable(\.cachedDownloadsTracker) var cachedDownloadsTracker: CachedDownloadsTracker

    @State var packageInstallTrackingNumber: Float = 0

    @FocusState var isSearchFieldFocused: Bool

    @State private var packageInstallationProcessStepTracker: PackageInstallationProcessStepTracker = .init()

    @State private var installationProgressTracker: InstallationProgressTracker? = nil

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
                sheetContent
                .navigationTitle(sheetTitle)
                .environment(installationProgressTracker)
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

                                await brewPackagesTracker.synchronizeInstalledPackages()
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
            Task
            {
                await brewPackagesTracker.synchronizeInstalledPackages()
                
                await cachedDownloadsTracker.loadCachedDownloadedPackages(
                    brewPackagesTracker: brewPackagesTracker
                )
            }
        }
    }
    
    @ViewBuilder
    private var sheetContent: some View
    {
        switch packageInstallationProcessStepTracker.currentStep
        {
        case .ready:
            InstallationInitialView(
                packageRequested: $packageRequested,
                onInstallationStart: startInstallation
            )
        case .searching(let forSearchString):
            InstallationSearchingView(
                packageRequested: forSearchString
            )
        case .presentingSearchResults(let forSearchString, let foundFormulae, let foundCasks):
            PresentingSearchResultsView(
                searchString: $packageRequested,
                foundFormulae: foundFormulae,
                foundCasks: foundCasks,
                onInstallationStart: startInstallation
            )
        case .installing(let package):
            if let installationProgressTracker
            {
                InstallingPackageView(packageToInstall: package, installationProgressTracker: installationProgressTracker)
            }
        case .finished:
            InstallationFinishedSuccessfullyView()
        case .unexpectedTerminalOutput(let unexpectedOutputType):
            if let installationProgressTracker
            {
                UnexpectedOutputsDuringPackageInstall(
                    unexpectedOutputType: unexpectedOutputType,
                    installationProgressTracker: installationProgressTracker
                )
            }
            
        case .erroredOut(let package, let withError):
            ErroredOutView(
                error: withError,
                packageThatWasBeingInstalled: package
            )
        }
    }
    
    // Assign the package properly, because `.onAppear` fucking flashes
    private func startInstallation(for package: MinimalHomebrewPackage) {
        installationProgressTracker = InstallationProgressTracker(packageToInstall: package)
        
        packageInstallationProcessStepTracker.advanceStep(to: .installing(package: package))
    }
}
