//
//  Installing.swift
//  Cork
//
//  Created by David Bureš on 29.09.2023.
//

import SwiftUI

struct InstallingPackageView: View
{
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var brewData: BrewDataStorage

    @ObservedObject var installationProgressTracker: InstallationProgressTracker

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
                        }
                        LiveTerminalOutputView(
                            lineArray: $installationProgressTracker.packageBeingInstalled.realTimeTerminalOutput,
                            isRealTimeTerminalOutputExpanded: $isShowingRealTimeOutput
                        )
                    }
                    .fixedSize()
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
        .task(priority: .userInitiated)
        {
            do
            {
                let installationResult = try await installationProgressTracker.installPackage(using: brewData)
                AppConstants.logger.debug("Installation result:\nStandard output: \(installationResult.standardOutput, privacy: .public)\nStandard error: \(installationResult.standardError, privacy: .public)")
            }
            catch let fatalInstallationError
            {
                AppConstants.logger.error("Fatal error occurred during installing a package: \(fatalInstallationError, privacy: .public)")
                
                dismiss()
                
                appState.showAlert(errorToShow: .fatalPackageInstallationError(fatalInstallationError.localizedDescription))
            }
        }
    }
}
