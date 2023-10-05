//
//  Installing.swift
//  Cork
//
//  Created by David Bureš on 29.09.2023.
//

import SwiftUI

struct InstallingPackageView: View
{
    @EnvironmentObject var brewData: BrewDataStorage

    @ObservedObject var installationProgressTracker: InstallationProgressTracker

    @Binding var packageInstallationProcessStep: PackageInstallationProcessSteps

    @State private var hadToEscalatePermissions: Bool = false

    var installedPackageName: String
    {
        return installationProgressTracker.packagesBeingInstalled[0].package.name
    }

    var body: some View
    {
        VStack(alignment: .leading)
        {
            ForEach(installationProgressTracker.packagesBeingInstalled)
            { packageBeingInstalled in

                if packageBeingInstalled.installationStage != .finished
                {
                    ProgressView(value: installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress, total: 10)
                    {
                        switch packageBeingInstalled.installationStage
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
                            Text("add-package.install.downloading-cask-\(installationProgressTracker.packagesBeingInstalled[0].package.name)")

                        case .installingCask:
                            Text("add-package.install.installing-cask-\(installationProgressTracker.packagesBeingInstalled[0].package.name)")

                        case .linkingCaskBinary:
                            Text("add-package.install.linking-cask-binary")

                        case .movingCask:
                            Text("add-package.install.moving-cask-\(installationProgressTracker.packagesBeingInstalled[0].package.name)")

                        case .requiresSudoPassword:
                            Text("add-package.install.requires-sudo-password-\(installationProgressTracker.packagesBeingInstalled[0].package.name)")
                                .task(priority: .userInitiated)
                                {
                                    do
                                    {
                                        let authorizationResult = try await escalatePermissions()
                                        print("Privilege escalation status: \(String(authStatus: authorizationResult))")
                                        print("Raw authorization value: \(authorizationResult)")

                                        /// Success
                                        if authorizationResult == 0
                                        {
                                            hadToEscalatePermissions = true

                                            print("Permission escalation tracker bool: \(hadToEscalatePermissions)")

                                            installationProgressTracker.packagesBeingInstalled[0].installationStage = .obtainedSudoPermissions
                                        }
                                    }
                                    catch let privilegeAuthorizationError
                                    {
                                        print("Error occured while getting elevated permissions: \(privilegeAuthorizationError)")

                                        packageInstallationProcessStep = .requiresSudoPassword
                                    }
                                }

                        case .obtainedSudoPermissions:
                            Text("add-package.install.installing-cask-\(installationProgressTracker.packagesBeingInstalled[0].package.name)")
                                .task(priority: .userInitiated)
                                {
                                    print("Had to escalate permissions during installation")

                                    installationProgressTracker.packagesBeingInstalled[0].installationStage = .installingCask
                                    installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress = 9

                                    do
                                    {
                                        if !installationProgressTracker.packagesBeingInstalled[0].package.isCask
                                        {
                                            try await sudoShell(AppConstants.brewExecutablePath.absoluteString, ["install", installedPackageName])
                                        }
                                        else
                                        {
                                            try await sudoShell(AppConstants.brewExecutablePath.absoluteString, ["install", "--no-quarantine", installedPackageName])
                                        }
                                    }
                                    catch let sudoShellError
                                    {
                                        print("Failed while executing sudo command: \(sudoShellError)")
                                    }
                                }
                        }
                    }
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
        }
        .task(priority: .userInitiated)
        {
            for var packageToInstall in installationProgressTracker.packagesBeingInstalled
            {
                do
                {
                    let installationResult = try await installPackage(installationProgressTracker: installationProgressTracker, brewData: brewData)
                    print("Installation result: \(installationResult)")
                }
                catch let fatalInstallationError
                {
                    print("Fatal error occured during installing a package: \(fatalInstallationError)")
                }
            }
        }
    }
}
