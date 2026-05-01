//
//  Add Package.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import CorkNotifications
import CorkShared
import SwiftUI
import ButtonKit
import Defaults
import CorkModels
import FactoryKit

typealias PackageInstallationProcessStepTracker = AddFormulaView.PackageInstallationProcessStepTracker

struct AddFormulaView: View
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
                    switch packageInstallationProcessStepTracker.currentStep {
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
                        InstallingPackageView(packageToInstall: package)
                    case .finished:
                        InstallationFinishedSuccessfullyView()
                    case .unexpectedTerminalOutput(let rawOutput):
                        EmptyView()
                    case .erroredOut(let withError):
                        EmptyView()
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
                                Text("action.cancel")
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
