//
//  Installing.swift
//  Cork
//
//  Created by David Bureš on 29.09.2023.
//

import SwiftUI
import CorkShared
import CorkModels
import CorkTerminalFunctions

struct InstallingPackageView: View
{
    @Environment(\.dismiss) var dismiss: DismissAction

    @Environment(AppState.self) var appState: AppState
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker
    
    @Environment(CachedDownloadsTracker.self) var cachedDownloadsTracker: CachedDownloadsTracker

    @Bindable var installationProgressTracker: InstallationProgressTracker

    @Binding var packageInstallationProcessStep: PackageInstallationProcessSteps

    @State var isShowingRealTimeOutput: Bool = false

    var body: some View
    {
        VStack(alignment: .leading)
        {
            if installationProgressTracker.packageBeingInstalled.installationStage != .finished
            {
                ProgressView(value: installationProgressTracker.packageBeingInstalled.packageInstallationProgress, total: 10)
                {
                    VStack(alignment: .leading)
                    {
                        switch installationProgressTracker.packageBeingInstalled.installationStage
                        {
                        case .ready:
                            Text("add-package.install.ready")

                        // FORMULAE
                        case .loadingDependencies:
                            Text("add-package.install.loading-dependencies")

                        case .fetchingDependencies:
                            Text("add-package.install.fetching-dependencies")

                        case .installingDependencies:
                            Text("add-package.install.installing-dependencies-\(installationProgressTracker.numberInLineOfPackageCurrentlyBeingInstalled)-of-\(installationProgressTracker.numberOfPackageDependencies)")

                        case .installingPackage:
                            Text("add-package.install.installing-package")

                        case .finished:
                            Text("add-package.install.finished")

                        // CASKS
                        case .downloadingCask:
                            Text("add-package.install.downloading-cask-\(installationProgressTracker.packageBeingInstalled.package.name)")

                        case .installingCask:
                            Text("add-package.install.installing-cask-\(installationProgressTracker.packageBeingInstalled.package.name)")

                        case .linkingCaskBinary:
                            Text("add-package.install.linking-cask-binary")

                        case .movingCask:
                            Text("add-package.install.moving-cask-\(installationProgressTracker.packageBeingInstalled.package.name)")

                        case .requiresSudoPassword:
                            Text("add-package.install.requires-sudo-password-\(installationProgressTracker.packageBeingInstalled.package.name)")
                                .onAppear
                                {
                                    packageInstallationProcessStep = .requiresSudoPassword
                                }

                        case .wrongArchitecture:
                            Text("add-package.install.wrong-architecture.title")
                                .onAppear
                                {
                                    packageInstallationProcessStep = .wrongArchitecture
                                }

                        case .binaryAlreadyExists:
                            Text("add-package.install.binary-already-exists-\(installationProgressTracker.packageBeingInstalled.package.name)")
                                .onAppear
                                {
                                    packageInstallationProcessStep = .binaryAlreadyExists
                                }

                        case .terminatedUnexpectedly:
                            Text("add-package.install.installation-terminated.title")
                                .onAppear
                                {
                                    packageInstallationProcessStep = .installationTerminatedUnexpectedly
                                }
                        }
                        LiveTerminalOutputView(
                            lineArray: $installationProgressTracker.packageBeingInstalled.realTimeTerminalOutput,
                            isRealTimeTerminalOutputExpanded: $isShowingRealTimeOutput
                        )
                    }
                }
                .allAnimationsDisabled()
            }
            else
            { // Show this when the installation is finished
                Text("add-package.install.finished")
                    .onAppear
                    {
                        packageInstallationProcessStep = .finished
                    }
            }
        }
        .task
        {
            do
            {
                let installationResult: TerminalOutput = try await installationProgressTracker.installPackage(
                    using: brewPackagesTracker,
                    cachedDownloadsTracker: cachedDownloadsTracker
                )
                
                AppConstants.shared.logger.debug("Installation result:\nStandard output: \(installationResult.standardOutput, privacy: .public)\nStandard error: \(installationResult.standardError, privacy: .public)")

                /// Check if the package installation stag at the end of the install process was something unexpected. Normal package installations go through multiple steps, and the three listed below are not supposed to be the end state. This means that something went wrong during the installation
                let installationStage: PackageInstallationStage = installationProgressTracker.packageBeingInstalled.installationStage
                if [.installingCask, .installingPackage, .ready].contains(installationStage)
                {
                    AppConstants.shared.logger.warning("The installation process quit before it was supposed to")

                    installationProgressTracker.packageBeingInstalled.installationStage = .terminatedUnexpectedly
                }
            }
            catch let fatalInstallationError
            {
                AppConstants.shared.logger.error("Fatal error occurred during installing a package: \(fatalInstallationError, privacy: .public)")

                dismiss()

                appState.showAlert(errorToShow: .fatalPackageInstallationError(fatalInstallationError.localizedDescription))
            }
        }
    }
}
