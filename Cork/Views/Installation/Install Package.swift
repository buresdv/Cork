//
//  Add Package.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import ButtonKit
import CorkNotifications
import CorkShared
import SwiftUI

struct AddFormulaView: View
{
    struct PackageSelectedToBeInstalled: Identifiable, Equatable, Hashable, Codable
    {
        var id: UUID
        
        var package: BrewPackage?
        
        var version: String?
        
        init(package: BrewPackage? = nil, version: String? = nil) {
            self.package = package
            self.version = version
            
            self.id = package?.id ?? .init()
        }
        
        /// Create a package with the relevant version selected, for previewing and installing
        func constructPackageOfRelevantVersion() -> BrewPackage?
        {
            /// First, see if there's a package to construct
            guard var newPackage = self.package else
            {
                /// If not, just return nil and the process will fail
                return nil
            }
            
            /// Now that we have a package, let's see if there's a specific Homebrew version selected
            if let selectedHomebrewVersion = self.version
            {
                /// If there is a version defined, construct a package that's identical, apart from its Homebrew version
                newPackage.versions = .init()
                newPackage.homebrewVersion = selectedHomebrewVersion
                
                return newPackage
            }
            else
            {
                /// If there's no Homebrew version defined, just return the package itself with no versions
                return newPackage
            }
        }
    }
    
    @Environment(\.dismiss) var dismiss: DismissAction

    @State private var packageRequested: String = ""

    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var appState: AppState

    @EnvironmentObject var cachedDownloadsTracker: CachedPackagesTracker

    @State private var foundPackageSelection: PackageSelectedToBeInstalled?

    @ObservedObject var searchResultTracker: SearchResultTracker = .init()
    @ObservedObject var installationProgressTracker: InstallationProgressTracker = .init()

    @State var packageInstallationProcessStep: PackageInstallationProcessSteps = .ready

    @State var packageInstallTrackingNumber: Float = 0

    @FocusState var isSearchFieldFocused: Bool

    @AppStorage("showPackagesStillLeftToInstall") var showPackagesStillLeftToInstall: Bool = false
    @AppStorage("notifyAboutPackageInstallationResults") var notifyAboutPackageInstallationResults: Bool = false

    var shouldShowSheetTitle: Bool
    {
        [.ready, .presentingSearchResults].contains(packageInstallationProcessStep)
    }

    var isDismissable: Bool
    {
        if case .installing = packageInstallationProcessStep
        {
            return true
        }

        if case .binaryAlreadyExists = packageInstallationProcessStep
        {
            return true
        }

        if case .fatalError = packageInstallationProcessStep
        {
            return true
        }

        if case .wrongArchitecture = packageInstallationProcessStep
        {
            return true
        }

        if case .requiresSudoPassword = packageInstallationProcessStep
        {
            return true
        }

        return [.ready, .presentingSearchResults, .anotherProcessAlreadyRunning, .anotherProcessAlreadyRunning, .installationTerminatedUnexpectedly].contains(packageInstallationProcessStep)
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
        }
    }

    var body: some View
    {
        NavigationStack
        {
            SheetTemplate(isShowingTitle: shouldShowSheetTitle)
            {
#if DEBUG
                        Text("\(foundPackageSelection?.package?.name ?? "nil"): \(foundPackageSelection?.version ?? "nil")")
#endif
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

                    case .installing(let packageToInstall):
                        InstallingPackageView(
                            installationProgressTracker: installationProgressTracker,
                            packageToInstall: packageToInstall,
                            packageInstallationProcessStep: $packageInstallationProcessStep
                        )

                    case .finished:
                        InstallationFinishedSuccessfullyView()

                    case .fatalError(let packageThatWasGettingInstalled): /// This shows up when the function for executing the install action throws an error
                        InstallationFatalErrorView(
                            installationProgressTracker: installationProgressTracker,
                            packageThatWasGettingInstalled: packageThatWasGettingInstalled
                        )

                    case .requiresSudoPassword(let packageThatWasGettingInstalled):
                        SudoRequiredView(
                            packageThatWasGettingInstalled: packageThatWasGettingInstalled
                        )

                    case .wrongArchitecture(let packageThatWasGettingInstalled):
                        WrongArchitectureView(
                            packageThatWasGettingInstalled: packageThatWasGettingInstalled
                        )

                    case .binaryAlreadyExists(let packageThatWasGettingInstalled):
                        BinaryAlreadyExistsView(installationProgressTracker: installationProgressTracker, packageThatWasGettingInstalled: packageThatWasGettingInstalled)

                    case .anotherProcessAlreadyRunning:
                        AnotherProcessAlreadyRunningView()

                    case .installationTerminatedUnexpectedly:
                        InstallationTerminatedUnexpectedlyView(terminalOutputOfTheInstallation: installationProgressTracker.realTimeTerminalOutput)
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
                                    try await brewData.synchronizeInstalledPackages(cachedPackagesTracker: cachedDownloadsTracker)
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
            cachedDownloadsTracker.assignPackageTypeToCachedDownloads(brewData: brewData)
        }
    }
}
