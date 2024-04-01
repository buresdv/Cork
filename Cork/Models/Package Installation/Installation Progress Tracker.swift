//
//  Installation Progress Tracker.swift
//  Cork
//
//  Created by David Bureš on 22.02.2023.
//

import Foundation

class InstallationProgressTracker: ObservableObject
{
    @Published var packageBeingCurrentlyInstalled: String = ""

    @Published var packagesBeingInstalled: [PackageInProgressOfBeingInstalled] = .init()
    
    @Published var numberOfPackageDependencies: Int = 0
    @Published var numberInLineOfPackageCurrentlyBeingFetched: Int = 0
    @Published var numberInLineOfPackageCurrentlyBeingInstalled: Int = 0

    @MainActor
    func installPackage(using brewData: BrewDataStorage) async throws -> TerminalOutput {
        let showRealTimeTerminalOutputs = UserDefaults.standard.bool(forKey: "showRealTimeTerminalOutputOfOperations")

        AppConstants.logger.debug("Installing package \(self.packagesBeingInstalled[0].package.name, privacy: .auto)")

        var installationResult = TerminalOutput(standardOutput: "", standardError: "")

        /// For some reason, the line `fetching [package name]` appears twice during the matching process, and the first one is a dud. Ignore that first one.
        var hasAlreadyMatchedLineAboutInstallingPackageItself = false

        var packageDependencies: [String] = .init()

        if !self.packagesBeingInstalled[0].package.isCask
        {
            AppConstants.logger.info("Package \(self.packagesBeingInstalled[0].package.name, privacy: .public) is Formula")

            for await output in shell(AppConstants.brewExecutablePath, ["install", self.packagesBeingInstalled[0].package.name])
            {
                switch output
                {
                case let .standardOutput(outputLine):

                    AppConstants.logger.debug("Package instrall line out: \(outputLine, privacy: .public)")

                    if showRealTimeTerminalOutputs
                    {
                        self.packagesBeingInstalled[0].realTimeTerminalOutput.append(RealTimeTerminalLine(line: outputLine))
                    }

                    AppConstants.logger.info("Does the line contain an element from the array? \(outputLine.containsElementFromArray(packageDependencies), privacy: .public)")

                    if outputLine.contains("Fetching dependencies")
                    {
                        // First, we have to get a list of all the dependencies
                        let dependencyMatchingRegex: String = "(?<=\(self.packagesBeingInstalled[0].package.name): ).*?(.*)"
                        var matchedDependencies = try regexMatch(from: outputLine, regex: dependencyMatchingRegex)
                        matchedDependencies = matchedDependencies.replacingOccurrences(of: " and", with: ",") // The last dependency is different, because it's preceded by "and" instead of "," so let's replace that "and" with "," so we can split it nicely

                        AppConstants.logger.debug("Matched Dependencies: \(matchedDependencies, privacy: .auto)")

                        packageDependencies = matchedDependencies.components(separatedBy: ", ") // Make the dependency list into an array

                        AppConstants.logger.debug("Package Dependencies: \(packageDependencies)")

                        AppConstants.logger.debug("Will fetch \(packageDependencies.count) dependencies!")

                        self.numberOfPackageDependencies = packageDependencies.count // Assign the number of dependencies to the tracker for the user to see

                        self.packagesBeingInstalled[0].packageInstallationProgress = 1
                    }

                    else if outputLine.contains("Installing dependencies") || outputLine.contains("Installing \(self.packagesBeingInstalled[0].package.name) dependency")
                    {
                        AppConstants.logger.info("Will install dependencies!")
                        self.packagesBeingInstalled[0].installationStage = .installingDependencies

                        // Increment by 1 for each package that finished installing
                        self.numberInLineOfPackageCurrentlyBeingInstalled = self.numberInLineOfPackageCurrentlyBeingInstalled + 1
                        AppConstants.logger.info("Installing dependency \(self.numberInLineOfPackageCurrentlyBeingInstalled) of \(packageDependencies.count)")

                        // TODO: Add a math formula for advancing the stepper
                        self.packagesBeingInstalled[0].packageInstallationProgress = self.packagesBeingInstalled[0].packageInstallationProgress + Double(Double(10) / (Double(3) * Double(self.numberOfPackageDependencies)))
                    }

                    else if outputLine.contains("Already downloaded") || (outputLine.contains("Fetching") && outputLine.containsElementFromArray(packageDependencies))
                    {
                        AppConstants.logger.info("Will fetch dependencies!")
                        self.packagesBeingInstalled[0].installationStage = .fetchingDependencies

                        self.numberInLineOfPackageCurrentlyBeingFetched = self.numberInLineOfPackageCurrentlyBeingFetched + 1

                        AppConstants.logger.info("Fetching dependency \(self.numberInLineOfPackageCurrentlyBeingFetched) of \(packageDependencies.count)")

                        self.packagesBeingInstalled[0].packageInstallationProgress = self.packagesBeingInstalled[0].packageInstallationProgress + Double(Double(10) / (Double(3) * (Double(self.numberOfPackageDependencies) * Double(5))))
                    }

                    else if outputLine.contains("Fetching \(self.packagesBeingInstalled[0].package.name)") || outputLine.contains("Installing \(self.packagesBeingInstalled[0].package.name)")
                    {
                        if hasAlreadyMatchedLineAboutInstallingPackageItself
                        { /// Only the second line about the package being installed is valid
                            AppConstants.logger.info("Will install the package itself!")
                            self.packagesBeingInstalled[0].installationStage = .installingPackage

                            // TODO: Add a math formula for advancing the stepper
                            self.packagesBeingInstalled[0].packageInstallationProgress = Double(self.packagesBeingInstalled[0].packageInstallationProgress) + Double((Double(10) - Double(self.packagesBeingInstalled[0].packageInstallationProgress)) / Double(2))

                            AppConstants.logger.info("Stepper value: \(Double(Double(10) / (Double(3) * Double(self.numberOfPackageDependencies))))")
                        }
                        else
                        { /// When it appears for the first time, ignore it
                            AppConstants.logger.info("Matched the dud line about the package itself being installed!")
                            hasAlreadyMatchedLineAboutInstallingPackageItself = true
                            self.packagesBeingInstalled[0].packageInstallationProgress = Double(self.packagesBeingInstalled[0].packageInstallationProgress) + Double((Double(10) - Double(self.packagesBeingInstalled[0].packageInstallationProgress)) / Double(2))
                        }
                    }

                    installationResult.standardOutput.append(outputLine)

                    AppConstants.logger.debug("Current installation stage: \(self.packagesBeingInstalled[0].installationStage.description, privacy: .public)")

                case let .standardError(errorLine):
                    AppConstants.logger.error("Errored out: \(errorLine, privacy: .public)")

                    if showRealTimeTerminalOutputs
                    {
                        self.packagesBeingInstalled[0].realTimeTerminalOutput.append(RealTimeTerminalLine(line: errorLine))
                    }

                    if errorLine.contains("a password is required")
                    {
                        AppConstants.logger.warning("Install requires sudo")

                        self.packagesBeingInstalled[0].installationStage = .requiresSudoPassword
                    }
                }
            }

            self.packagesBeingInstalled[0].packageInstallationProgress = 10

            self.packagesBeingInstalled[0].installationStage = .finished
        }
        else
        {
            AppConstants.logger.info("Package is Cask")
            AppConstants.logger.debug("Installing package \(self.packagesBeingInstalled[0].package.name, privacy: .public)")

            for await output in shell(AppConstants.brewExecutablePath, ["install", "--no-quarantine", self.packagesBeingInstalled[0].package.name])
            {
                switch output
                {
                case let .standardOutput(outputLine):
                    AppConstants.logger.info("Output line: \(outputLine, privacy: .public)")

                    if showRealTimeTerminalOutputs
                    {
                        self.packagesBeingInstalled[0].realTimeTerminalOutput.append(RealTimeTerminalLine(line: outputLine))
                    }

                    if outputLine.contains("Downloading")
                    {
                        AppConstants.logger.info("Will download Cask")

                        self.packagesBeingInstalled[0].packageInstallationProgress = self.packagesBeingInstalled[0].packageInstallationProgress + 2

                        self.packagesBeingInstalled[0].installationStage = .downloadingCask
                    }
                    else if outputLine.contains("Installing Cask")
                    {
                        AppConstants.logger.info("Will install Cask")

                        self.packagesBeingInstalled[0].packageInstallationProgress = self.packagesBeingInstalled[0].packageInstallationProgress + 2

                        self.packagesBeingInstalled[0].installationStage = .installingCask
                    }
                    else if outputLine.contains("Moving App")
                    {
                        AppConstants.logger.info("Moving App")

                        self.packagesBeingInstalled[0].packageInstallationProgress = self.packagesBeingInstalled[0].packageInstallationProgress + 2

                        self.packagesBeingInstalled[0].installationStage = .movingCask
                    }
                    else if outputLine.contains("Linking binary")
                    {
                        AppConstants.logger.info("Linking Binary")

                        self.packagesBeingInstalled[0].packageInstallationProgress = self.packagesBeingInstalled[0].packageInstallationProgress + 2

                        self.packagesBeingInstalled[0].installationStage = .linkingCaskBinary
                    }
                    else if outputLine.contains("was successfully installed")
                    {
                        AppConstants.logger.info("Finished installing app")

                        self.packagesBeingInstalled[0].installationStage = .finished

                        self.packagesBeingInstalled[0].packageInstallationProgress = 10
                    }

                case let .standardError(errorLine):
                    AppConstants.logger.error("Line had error: \(errorLine, privacy: .public)")

                    if showRealTimeTerminalOutputs
                    {
                        self.packagesBeingInstalled[0].realTimeTerminalOutput.append(RealTimeTerminalLine(line: errorLine))
                    }

                    if errorLine.contains("a password is required")
                    {
                        AppConstants.logger.warning("Install requires sudo")

                        self.packagesBeingInstalled[0].installationStage = .requiresSudoPassword
                    }
                    else if errorLine.contains(/depends on hardware architecture being.+but you are running/)
                    {
                        AppConstants.logger.warning("Package is wrong architecture")

                        self.packagesBeingInstalled[0].installationStage = .wrongArchitecture
                    }
                }
            }
        }

        await synchronizeInstalledPackages(brewData: brewData)

        return installationResult
    }
}
