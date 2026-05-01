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

struct AddFormulaView: View
{
    @Environment(\.dismiss) var dismiss: DismissAction

    @State private var packageRequested: String = ""

    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker
    @InjectedObservable(\.appState) var appState: AppState

    @Environment(CachedDownloadsTracker.self) var cachedDownloadsTracker: CachedDownloadsTracker

    @State private var foundPackageSelection: BrewPackage?

    @State var packageInstallationProcessStep: PackageInstallationProcessSteps = .ready

    @State var packageInstallTrackingNumber: Float = 0

    @FocusState var isSearchFieldFocused: Bool
    
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
                    switch packageInstallationProcessStep {
                    case .ready:
                        InstallationInitialView(packageRequested: <#T##Binding<String>#>, foundPackageSelection: <#T##Binding<BrewPackage?>#>, packageToInstall: <#T##MinimalHomebrewPackage#>, packageInstallationProcessStep: <#T##Binding<PackageInstallationProcessSteps>#>)
                    case .searching(let forSearchString):
                        <#code#>
                    case .presentingSearchResults(let forSearchString, let foundFormulae, let foundCasks):
                        <#code#>
                    case .installing(let package):
                        <#code#>
                    case .finished:
                        <#code#>
                    case .unexpectedTerminalOutput(let rawOutput):
                        <#code#>
                    case .erroredOut(let withError):
                        <#code#>
                    }
                    switch packageInstallationProcessStep
                    {
                    case .ready:
                        InstallationInitialView(
                            packageRequested: $packageRequested,
                            foundPackageSelection: $foundPackageSelection,
                            packageToInstall: <#MinimalHomebrewPackage#>, packageInstallationProcessStep: $packageInstallationProcessStep
                        )

                    case .searching(let forSearchString):
                        InstallationSearchingView(
                            packageRequested: $packageRequested,
                            packageInstallationProcessStep: $packageInstallationProcessStep
                        )

                    case .presentingSearchResults(let forSearchString, let foundFormulae, let foundCasks):
                        PresentingSearchResultsView(
                            packageRequested: $packageRequested,
                            foundPackageSelection: $foundPackageSelection,
                            packageInstallationProcessStep: $packageInstallationProcessStep,
                            installationProgressTracker: installationProgressTracker
                        )

                    case .installing(let package):
                        InstallingPackageView(
                            installationProgressTracker: installationProgressTracker,
                            packageInstallationProcessStep: $packageInstallationProcessStep
                        )

                    case .finished:
                        InstallationFinishedSuccessfullyView()

                    case .fatalError: /// This shows up when the function for executing the install action throws an error
                        InstallationFatalErrorView(packageBeingInstalled: installationProgressTracker.packageBeingInstalled.package)

                    case .requiresSudoPassword:
                        SudoRequiredView(installationProgressTracker: installationProgressTracker)

                    case .wrongArchitecture:
                        WrongArchitectureView(installationProgressTracker: installationProgressTracker)

                    case .binaryAlreadyExists:
                        BinaryAlreadyExistsView(
                            installationProgressTracker: installationProgressTracker,
                            packageInstallationProcessStep: $packageInstallationProcessStep
                        )

                    case .anotherProcessAlreadyRunning:
                        AnotherProcessAlreadyRunningView()

                    case .installationTerminatedUnexpectedly:
                        InstallationTerminatedUnexpectedlyView(
                            terminalOutputOfTheInstallation: installationProgressTracker.packageBeingInstalled.realTimeTerminalOutput
                        )
                        
                    case .adoptingAlreadyInstalledCask:
                        AdoptingAlreadyInstalledCaskView(
                            installationProgressTracker: installationProgressTracker
                        )
                    }
                }
                .navigationTitle(sheetTitle)
                .toolbar
                {
                    if packageInstallationProcessStep.isDismissable
                    {
                        ToolbarItem(placement: .cancellationAction)
                        {
                            AsyncButton
                            {
                                dismiss()
                                installationProgressTracker.installationProcess.cancel()
                                
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
