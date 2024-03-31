//
//  Install Selected Packages.swift
//  Cork
//
//  Created by David Bureš on 04.07.2022.
//

import Foundation
import SwiftUI

enum InstallationError: Error
{
    case outputHadErrors
}

@MainActor
func installPackage(installationProgressTracker: InstallationProgressTracker, brewData: BrewDataStorage) async throws -> TerminalOutput
{
    let showRealTimeTerminalOutputs = UserDefaults.standard.bool(forKey: "showRealTimeTerminalOutputOfOperations")

    AppConstants.logger.debug("Installing package \(installationProgressTracker.packagesBeingInstalled[0].package.name, privacy: .auto)")

    var installationResult = TerminalOutput(standardOutput: "", standardError: "")

    /// For some reason, the line `fetching [package name]` appears twice during the matching process, and the first one is a dud. Ignore that first one.
    var hasAlreadyMatchedLineAboutInstallingPackageItself = false

    var packageDependencies: [String] = .init()

    if !installationProgressTracker.packagesBeingInstalled[0].package.isCask
    {
        AppConstants.logger.info("Package \(installationProgressTracker.packagesBeingInstalled[0].package.name, privacy: .public) is Formula")

        for await output in shell(AppConstants.brewExecutablePath, ["install", installationProgressTracker.packagesBeingInstalled[0].package.name])
        {
            switch output
            {
            case let .standardOutput(outputLine):

                AppConstants.logger.debug("Package instrall line out: \(outputLine, privacy: .public)")

                if showRealTimeTerminalOutputs
                {
                    installationProgressTracker.packagesBeingInstalled[0].realTimeTerminalOutput.append(RealTimeTerminalLine(line: outputLine))
                }

                AppConstants.logger.info("Does the line contain an element from the array? \(outputLine.containsElementFromArray(packageDependencies), privacy: .public)")

                if outputLine.contains("Fetching dependencies")
                {
                    // First, we have to get a list of all the dependencies
                    let dependencyMatchingRegex: String = "(?<=\(installationProgressTracker.packagesBeingInstalled[0].package.name): ).*?(.*)"
                    var matchedDependencies = try regexMatch(from: outputLine, regex: dependencyMatchingRegex)
                    matchedDependencies = matchedDependencies.replacingOccurrences(of: " and", with: ",") // The last dependency is different, because it's preceded by "and" instead of "," so let's replace that "and" with "," so we can split it nicely

                    AppConstants.logger.debug("Matched Dependencies: \(matchedDependencies, privacy: .auto)")

                    packageDependencies = matchedDependencies.components(separatedBy: ", ") // Make the dependency list into an array

                    AppConstants.logger.debug("Package Dependencies: \(packageDependencies)")

                    AppConstants.logger.debug("Will fetch \(packageDependencies.count) dependencies!")

                    installationProgressTracker.numberOfPackageDependencies = packageDependencies.count // Assign the number of dependencies to the tracker for the user to see

                    installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress = 1
                }

                else if outputLine.contains("Installing dependencies") || outputLine.contains("Installing \(installationProgressTracker.packagesBeingInstalled[0].package.name) dependency")
                {
                    AppConstants.logger.info("Will install dependencies!")
                    installationProgressTracker.packagesBeingInstalled[0].installationStage = .installingDependencies

                    // Increment by 1 for each package that finished installing
                    installationProgressTracker.numberInLineOfPackageCurrentlyBeingInstalled = installationProgressTracker.numberInLineOfPackageCurrentlyBeingInstalled + 1
                    AppConstants.logger.info("Installing dependency \(installationProgressTracker.numberInLineOfPackageCurrentlyBeingInstalled) of \(packageDependencies.count)")

                    // TODO: Add a math formula for advancing the stepper
                    installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress = installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress + Double(Double(10) / (Double(3) * Double(installationProgressTracker.numberOfPackageDependencies)))
                }

                else if outputLine.contains("Already downloaded") || (outputLine.contains("Fetching") && outputLine.containsElementFromArray(packageDependencies))
                {
                    AppConstants.logger.info("Will fetch dependencies!")
                    installationProgressTracker.packagesBeingInstalled[0].installationStage = .fetchingDependencies

                    installationProgressTracker.numberInLineOfPackageCurrentlyBeingFetched = installationProgressTracker.numberInLineOfPackageCurrentlyBeingFetched + 1

                    AppConstants.logger.info("Fetching dependency \(installationProgressTracker.numberInLineOfPackageCurrentlyBeingFetched) of \(packageDependencies.count)")

                    installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress = installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress + Double(Double(10) / (Double(3) * (Double(installationProgressTracker.numberOfPackageDependencies) * Double(5))))
                }

                else if outputLine.contains("Fetching \(installationProgressTracker.packagesBeingInstalled[0].package.name)") || outputLine.contains("Installing \(installationProgressTracker.packagesBeingInstalled[0].package.name)")
                {
                    if hasAlreadyMatchedLineAboutInstallingPackageItself
                    { /// Only the second line about the package being installed is valid
                        AppConstants.logger.info("Will install the package itself!")
                        installationProgressTracker.packagesBeingInstalled[0].installationStage = .installingPackage

                        // TODO: Add a math formula for advancing the stepper
                        installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress = Double(installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress) + Double((Double(10) - Double(installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress)) / Double(2))

                        AppConstants.logger.info("Stepper value: \(Double(Double(10) / (Double(3) * Double(installationProgressTracker.numberOfPackageDependencies))))")
                    }
                    else
                    { /// When it appears for the first time, ignore it
                        AppConstants.logger.info("Matched the dud line about the package itself being installed!")
                        hasAlreadyMatchedLineAboutInstallingPackageItself = true
                        installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress = Double(installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress) + Double((Double(10) - Double(installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress)) / Double(2))
                    }
                }

                installationResult.standardOutput.append(outputLine)

                AppConstants.logger.debug("Current installation stage: \(installationProgressTracker.packagesBeingInstalled[0].installationStage.description, privacy: .public)")

            case let .standardError(errorLine):
                AppConstants.logger.error("Errored out: \(errorLine, privacy: .public)")

                if showRealTimeTerminalOutputs
                {
                    installationProgressTracker.packagesBeingInstalled[0].realTimeTerminalOutput.append(RealTimeTerminalLine(line: errorLine))
                }

                if errorLine.contains("a password is required")
                {
                    AppConstants.logger.warning("Install requires sudo")

                    installationProgressTracker.packagesBeingInstalled[0].installationStage = .requiresSudoPassword
                }
            }
        }

        installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress = 10

        installationProgressTracker.packagesBeingInstalled[0].installationStage = .finished
    }
    else
    {
        AppConstants.logger.info("Package is Cask")
        AppConstants.logger.debug("Installing package \(installationProgressTracker.packagesBeingInstalled[0].package.name, privacy: .public)")

        for await output in shell(AppConstants.brewExecutablePath, ["install", "--no-quarantine", installationProgressTracker.packagesBeingInstalled[0].package.name])
        {
            switch output
            {
            case let .standardOutput(outputLine):
                AppConstants.logger.info("Output line: \(outputLine, privacy: .public)")

                if showRealTimeTerminalOutputs
                {
                    installationProgressTracker.packagesBeingInstalled[0].realTimeTerminalOutput.append(RealTimeTerminalLine(line: outputLine))
                }

                if outputLine.contains("Downloading")
                {
                    AppConstants.logger.info("Will download Cask")

                    installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress = installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress + 2

                    installationProgressTracker.packagesBeingInstalled[0].installationStage = .downloadingCask
                }
                else if outputLine.contains("Installing Cask")
                {
                    AppConstants.logger.info("Will install Cask")

                    installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress = installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress + 2

                    installationProgressTracker.packagesBeingInstalled[0].installationStage = .installingCask
                }
                else if outputLine.contains("Moving App")
                {
                    AppConstants.logger.info("Moving App")

                    installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress = installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress + 2

                    installationProgressTracker.packagesBeingInstalled[0].installationStage = .movingCask
                }
                else if outputLine.contains("Linking binary")
                {
                    AppConstants.logger.info("Linking Binary")

                    installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress = installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress + 2

                    installationProgressTracker.packagesBeingInstalled[0].installationStage = .linkingCaskBinary
                }
                else if outputLine.contains("was successfully installed")
                {
                    AppConstants.logger.info("Finished installing app")

                    installationProgressTracker.packagesBeingInstalled[0].installationStage = .finished

                    installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress = 10
                }

            case let .standardError(errorLine):
                AppConstants.logger.error("Line had error: \(errorLine, privacy: .public)")

                if showRealTimeTerminalOutputs
                {
                    installationProgressTracker.packagesBeingInstalled[0].realTimeTerminalOutput.append(RealTimeTerminalLine(line: errorLine))
                }

                if errorLine.contains("a password is required")
                {
                    AppConstants.logger.warning("Install requires sudo")

                    installationProgressTracker.packagesBeingInstalled[0].installationStage = .requiresSudoPassword
                }
                else if errorLine.contains("depends on hardware architecture being.+but you are running")
                {
                    AppConstants.logger.warning("Package is wrong architecture")

                    installationProgressTracker.packagesBeingInstalled[0].installationStage = .wrongArchitecture
                }
            }
        }
    }

    await synchronizeInstalledPackages(brewData: brewData)

    return installationResult
}
