//
//  Install Cask.swift
//  Cork
//
//  Created by David Bureš on 28.04.2026.
//

import CorkModels
import CorkShared
import CorkTerminalFunctions
import Foundation

extension InstallationProgressTracker
{
    @MainActor
    func installCask() async throws(InstallationError.ImplementedError.CaskInstallError)
    {
        let package: BrewPackage = packageBeingInstalled.package

        AppConstants.shared.logger.info("Package is Cask")
        AppConstants.shared.logger.debug("Installing package \(package.name(withPrecision: .precise), privacy: .public)")

        let (stream, process): (AsyncStream<TerminalOutput>, Process) = shell(AppConstants.shared.brewExecutablePath, ["install", package.name(withPrecision: .precise)])
        installationProcess = process
        for await output in stream
        {
            self.insertOutput(output)

            switch output
            {
            case .standardOutput(let outputLine):
                AppConstants.shared.logger.info("Output line: \(outputLine, privacy: .public)")

                if outputLine.contains("Downloading")
                {
                    AppConstants.shared.logger.info("Will download Cask")

                    packageBeingInstalled.packageInstallationProgress = packageBeingInstalled.packageInstallationProgress + 2

                    packageBeingInstalled.installationStage = .downloadingCask
                }
                else if outputLine.contains("Installing Cask")
                {
                    AppConstants.shared.logger.info("Will install Cask")

                    packageBeingInstalled.packageInstallationProgress = packageBeingInstalled.packageInstallationProgress + 2

                    packageBeingInstalled.installationStage = .installingCask
                }
                else if outputLine.contains("Moving App")
                {
                    AppConstants.shared.logger.info("Moving App")

                    packageBeingInstalled.packageInstallationProgress = packageBeingInstalled.packageInstallationProgress + 2

                    packageBeingInstalled.installationStage = .movingCask
                }
                else if outputLine.contains("Linking binary")
                {
                    AppConstants.shared.logger.info("Linking Binary")

                    packageBeingInstalled.packageInstallationProgress = packageBeingInstalled.packageInstallationProgress + 2

                    packageBeingInstalled.installationStage = .linkingCaskBinary
                }
                else if outputLine.contains("Purging files")
                {
                    AppConstants.shared.logger.info("Purging old version of cask \(package.name(withPrecision: .precise), privacy: .public)")

                    packageBeingInstalled.installationStage = .installingCask

                    packageBeingInstalled.packageInstallationProgress = packageBeingInstalled.packageInstallationProgress + 1
                }
                else if outputLine.contains("was successfully installed")
                {
                    AppConstants.shared.logger.info("Finished installing app")

                    packageBeingInstalled.installationStage = .finished

                    packageBeingInstalled.packageInstallationProgress = 10
                }

            case .standardError(let errorLine):
                AppConstants.shared.logger.error("Line had error: \(errorLine, privacy: .public)")

                if errorLine.contains("a password is required")
                {
                    AppConstants.shared.logger.warning("Install requires sudo")

                    packageBeingInstalled.installationStage = .requiresSudoPassword
                }
                else if errorLine.contains("there is already an App at")
                {
                    AppConstants.shared.logger.warning("The app already exists")

                    packageBeingInstalled.installationStage = .binaryAlreadyExists
                }
                else if errorLine.contains(/depends on hardware architecture being.+but you are running/)
                {
                    AppConstants.shared.logger.warning("Package is wrong architecture")

                    packageBeingInstalled.installationStage = .wrongArchitecture
                }
            }
        }
    }
}
