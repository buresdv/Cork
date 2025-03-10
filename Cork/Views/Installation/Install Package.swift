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

struct AddFormulaView: View
{
    @Environment(\.dismiss) var dismiss: DismissAction

    @State private var packageRequested: String = ""

    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker
    @Environment(AppState.self) var appState: AppState

    @Environment(CachedDownloadsTracker.self) var cachedDownloadsTracker: CachedDownloadsTracker

    @State private var foundPackageSelection: BrewPackage?

    @ObservedObject var searchResultTracker: SearchResultTracker = .init()
    @Bindable var installationProgressTracker: InstallationProgressTracker = .init()

    @State var packageInstallationProcessStep: PackageInstallationProcessSteps = .ready

    @State var packageInstallTrackingNumber: Float = 0

    @FocusState var isSearchFieldFocused: Bool

    @AppStorage("showPackagesStillLeftToInstall") var showPackagesStillLeftToInstall: Bool = false
    @Default(.notifyAboutPackageInstallationResults) var notifyAboutPackageInstallationResults

    var shouldShowSheetTitle: Bool
    {
        [.ready, .presentingSearchResults].contains(packageInstallationProcessStep)
    }
    
    var isDismissable: Bool
    {
        [.ready, .presentingSearchResults, .fatalError, .anotherProcessAlreadyRunning, .binaryAlreadyExists, .requiresSudoPassword, .wrongArchitecture, .anotherProcessAlreadyRunning, .installationTerminatedUnexpectedly, .installing].contains(packageInstallationProcessStep)
    }

    var sheetTitle: LocalizedStringKey
    {
        switch packageInstallationProcessStep
        {
        case .ready:
            return "add-package.title"
        case .searching:
            return ""
        case .presentingSearchResults:
            return "add-package.title"
        case .installing:
            return ""
        case .finished:
            return ""
        case .fatalError:
            return ""
        case .requiresSudoPassword:
            return ""
        case .wrongArchitecture:
            return ""
        case .binaryAlreadyExists:
            return ""
        case .anotherProcessAlreadyRunning:
            return ""
        case .installationTerminatedUnexpectedly:
            return ""
        case .adoptingAlreadyInstalledCask:
            return ""
        }
    }

    var body: some View
    {
        NavigationStack
        {
            SheetTemplate(isShowingTitle: shouldShowSheetTitle)
            {
                Group
                {
                    switch packageInstallationProcessStep
                    {
                    case .ready:
                        InstallationInitialView(
                            searchResultTracker: searchResultTracker,
                            packageRequested: $packageRequested,
                            foundPackageSelection: $foundPackageSelection,
                            installationProgressTracker: installationProgressTracker,
                            packageInstallationProcessStep: $packageInstallationProcessStep
                        )

                    case .searching:
                        InstallationSearchingView(
                            packageRequested: $packageRequested,
                            searchResultTracker: searchResultTracker,
                            packageInstallationProcessStep: $packageInstallationProcessStep
                        )

                    case .presentingSearchResults:
                        PresentingSearchResultsView(
                            searchResultTracker: searchResultTracker,
                            packageRequested: $packageRequested,
                            foundPackageSelection: $foundPackageSelection,
                            packageInstallationProcessStep: $packageInstallationProcessStep,
                            installationProgressTracker: installationProgressTracker
                        )

                    case .installing:
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
                    if isDismissable
                    {
                        ToolbarItem(placement: .cancellationAction)
                        {
                            AsyncButton
                            {
                                dismiss()
                                installationProgressTracker.cancel()
                                
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
                try? await brewData.synchronizeInstalledPackages(cachedPackagesTracker: cachedDownloadsTracker)
            }
            
        }
    }
}
