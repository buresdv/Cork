//
//  Installation Progress Tracker.swift
//  Cork
//
//  Created by David Bureš on 22.02.2023.
//

import Foundation

class InstallationProgressTracker: ObservableObject
{  
    @Published var packageBeingInstalled: PackageInProgressOfBeingInstalled = .init(package: .init(name: "", isCask: false, installedOn: nil, versions: [], sizeInBytes: 0), installationStage: .downloadingCask, packageInstallationProgress: 0)
    
    @Published var numberOfPackageDependencies: Int = 0
    @Published var numberInLineOfPackageCurrentlyBeingFetched: Int = 0
    @Published var numberInLineOfPackageCurrentlyBeingInstalled: Int = 0

    private var showRealTimeTerminalOutputs: Bool
    {
        UserDefaults.standard.bool(forKey: "showRealTimeTerminalOutputOfOperations")
    }

    @MainActor
    func installPackage(using brewData: BrewDataStorage) async throws -> TerminalOutput 
    {
        let package = packageBeingInstalled.package

        AppConstants.logger.debug("Installing package \(package.name, privacy: .auto)")

        var installationResult = TerminalOutput(standardOutput: "", standardError: "")

        if !package.isCask
        {
            AppConstants.logger.info("Package \(package.name, privacy: .public) is Formula")

            let output = try await installFormula(using: brewData).joined(separator: "")

            installationResult.standardOutput.append(output)

            packageBeingInstalled.packageInstallationProgress = 10

            packageBeingInstalled.installationStage = .finished
        }
        else
        {
            AppConstants.logger.info("Package is Cask")
            try await installCask(using: brewData)
        }

        await synchronizeInstalledPackages(brewData: brewData)

        return installationResult
    }

    @MainActor
    private func installFormula(using brewData: BrewDataStorage) async throws -> [String]
    {
        let package = packageBeingInstalled.package
        var packageDependencies: [String] = .init()
        /// For some reason, the line `fetching [package name]` appears twice during the matching process, and the first one is a dud. Ignore that first one.
        var hasAlreadyMatchedLineAboutInstallingPackageItself = false
        var installOutput = [String]()

        AppConstants.logger.info("Package \(package.name, privacy: .public) is Formula")

        for await output in shell(AppConstants.brewExecutablePath, ["install", package.name])
        {
            switch output
            {
            case let .standardOutput(outputLine):

                AppConstants.logger.debug("Package instrall line out: \(outputLine, privacy: .public)")

                if showRealTimeTerminalOutputs
                {
                    packageBeingInstalled.realTimeTerminalOutput.append(RealTimeTerminalLine(line: outputLine))
                }

                AppConstants.logger.info("Does the line contain an element from the array? \(outputLine.containsElementFromArray(packageDependencies), privacy: .public)")

                if outputLine.contains("Fetching dependencies")
                {
                    // First, we have to get a list of all the dependencies
                    let dependencyMatchingRegex: String = "(?<=\(package.name): ).*?(.*)"
                    var matchedDependencies = try regexMatch(from: outputLine, regex: dependencyMatchingRegex)
                    matchedDependencies = matchedDependencies.replacingOccurrences(of: " and", with: ",") // The last dependency is different, because it's preceded by "and" instead of "," so let's replace that "and" with "," so we can split it nicely

                    AppConstants.logger.debug("Matched Dependencies: \(matchedDependencies, privacy: .auto)")

                    packageDependencies = matchedDependencies.components(separatedBy: ", ") // Make the dependency list into an array

                    AppConstants.logger.debug("Package Dependencies: \(packageDependencies)")

                    AppConstants.logger.debug("Will fetch \(packageDependencies.count) dependencies!")

                    self.numberOfPackageDependencies = packageDependencies.count // Assign the number of dependencies to the tracker for the user to see

                    packageBeingInstalled.packageInstallationProgress = 1
                }

                else if outputLine.contains("Installing dependencies") || outputLine.contains("Installing \(package.name) dependency")
                {
                    AppConstants.logger.info("Will install dependencies!")
                    packageBeingInstalled.installationStage = .installingDependencies

                    // Increment by 1 for each package that finished installing
                    self.numberInLineOfPackageCurrentlyBeingInstalled = self.numberInLineOfPackageCurrentlyBeingInstalled + 1
                    AppConstants.logger.info("Installing dependency \(self.numberInLineOfPackageCurrentlyBeingInstalled) of \(packageDependencies.count)")

                    // TODO: Add a math formula for advancing the stepper
                    packageBeingInstalled.packageInstallationProgress = packageBeingInstalled.packageInstallationProgress + Double(Double(10) / (Double(3) * Double(self.numberOfPackageDependencies)))
                }

                else if outputLine.contains("Already downloaded") || (outputLine.contains("Fetching") && outputLine.containsElementFromArray(packageDependencies))
                {
                    AppConstants.logger.info("Will fetch dependencies!")
                    packageBeingInstalled.installationStage = .fetchingDependencies

                    self.numberInLineOfPackageCurrentlyBeingFetched = self.numberInLineOfPackageCurrentlyBeingFetched + 1

                    AppConstants.logger.info("Fetching dependency \(self.numberInLineOfPackageCurrentlyBeingFetched) of \(packageDependencies.count)")

                    packageBeingInstalled.packageInstallationProgress = packageBeingInstalled.packageInstallationProgress + Double(Double(10) / (Double(3) * (Double(self.numberOfPackageDependencies) * Double(5))))
                }

                else if outputLine.contains("Fetching \(package.name)") || outputLine.contains("Installing \(package.name)")
                {
                    if hasAlreadyMatchedLineAboutInstallingPackageItself
                    { /// Only the second line about the package being installed is valid
                        AppConstants.logger.info("Will install the package itself!")
                        packageBeingInstalled.installationStage = .installingPackage

                        // TODO: Add a math formula for advancing the stepper
                        packageBeingInstalled.packageInstallationProgress = Double(packageBeingInstalled.packageInstallationProgress) + Double((Double(10) - Double(packageBeingInstalled.packageInstallationProgress)) / Double(2))

                        AppConstants.logger.info("Stepper value: \(Double(Double(10) / (Double(3) * Double(self.numberOfPackageDependencies))))")
                    }
                    else
                    { /// When it appears for the first time, ignore it
                        AppConstants.logger.info("Matched the dud line about the package itself being installed!")
                        hasAlreadyMatchedLineAboutInstallingPackageItself = true
                        packageBeingInstalled.packageInstallationProgress = Double(packageBeingInstalled.packageInstallationProgress) + Double((Double(10) - Double(packageBeingInstalled.packageInstallationProgress)) / Double(2))
                    }
                }

                installOutput.append(outputLine)

                AppConstants.logger.debug("Current installation stage: \(self.packageBeingInstalled.installationStage.description, privacy: .public)")

            case let .standardError(errorLine):
                AppConstants.logger.error("Errored out: \(errorLine, privacy: .public)")

                if showRealTimeTerminalOutputs
                {
                    packageBeingInstalled.realTimeTerminalOutput.append(RealTimeTerminalLine(line: errorLine))
                }

                if errorLine.contains("a password is required")
                {
                    AppConstants.logger.warning("Install requires sudo")

                    packageBeingInstalled.installationStage = .requiresSudoPassword
                }
            }
        }

        packageBeingInstalled.packageInstallationProgress = 10

        packageBeingInstalled.installationStage = .finished

        return installOutput
    }

    @MainActor
    func installCask(using brewData: BrewDataStorage) async throws
    {
        let package = packageBeingInstalled.package

        AppConstants.logger.info("Package is Cask")
        AppConstants.logger.debug("Installing package \(package.name, privacy: .public)")

        for await output in shell(AppConstants.brewExecutablePath, ["install", "--no-quarantine", package.name])
        {
            switch output
            {
            case let .standardOutput(outputLine):
                AppConstants.logger.info("Output line: \(outputLine, privacy: .public)")

                if showRealTimeTerminalOutputs
                {
                    packageBeingInstalled.realTimeTerminalOutput.append(RealTimeTerminalLine(line: outputLine))
                }

                if outputLine.contains("Downloading")
                {
                    AppConstants.logger.info("Will download Cask")

                    packageBeingInstalled.packageInstallationProgress = packageBeingInstalled.packageInstallationProgress + 2

                    packageBeingInstalled.installationStage = .downloadingCask
                }
                else if outputLine.contains("Installing Cask")
                {
                    AppConstants.logger.info("Will install Cask")

                    packageBeingInstalled.packageInstallationProgress = packageBeingInstalled.packageInstallationProgress + 2

                    packageBeingInstalled.installationStage = .installingCask
                }
                else if outputLine.contains("Moving App")
                {
                    AppConstants.logger.info("Moving App")

                    packageBeingInstalled.packageInstallationProgress = packageBeingInstalled.packageInstallationProgress + 2

                    packageBeingInstalled.installationStage = .movingCask
                }
                else if outputLine.contains("Linking binary")
                {
                    AppConstants.logger.info("Linking Binary")

                    packageBeingInstalled.packageInstallationProgress = packageBeingInstalled.packageInstallationProgress + 2

                    packageBeingInstalled.installationStage = .linkingCaskBinary
                }
                else if outputLine.contains("was successfully installed")
                {
                    AppConstants.logger.info("Finished installing app")

                    packageBeingInstalled.installationStage = .finished

                    packageBeingInstalled.packageInstallationProgress = 10
                }

            case let .standardError(errorLine):
                AppConstants.logger.error("Line had error: \(errorLine, privacy: .public)")

                if showRealTimeTerminalOutputs
                {
                    packageBeingInstalled.realTimeTerminalOutput.append(RealTimeTerminalLine(line: errorLine))
                }

                if errorLine.contains("a password is required")
                {
                    AppConstants.logger.warning("Install requires sudo")

                    packageBeingInstalled.installationStage = .requiresSudoPassword
                }
                else if errorLine.contains(/depends on hardware architecture being.+but you are running/)
                {
                    AppConstants.logger.warning("Package is wrong architecture")

                    packageBeingInstalled.installationStage = .wrongArchitecture
                }
            }
        }
    }
}
