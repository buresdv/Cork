//
//  Installation Progress Tracker.swift
//  Cork
//
//  Created by David Bureš on 22.02.2023.
//

import Foundation
import CorkShared

class InstallationProgressTracker: ObservableObject
{
    @Published var installationStage: PackageInstallationStage = .downloadingCask
    @Published var installationProgress: Double = 0
    
    @Published var realTimeTerminalOutput: [RealTimeTerminalLine] = .init()
    
    @Published var numberOfPackageDependencies: Int = 0
    @Published var numberInLineOfPackageCurrentlyBeingFetched: Int = 0
    @Published var numberInLineOfPackageCurrentlyBeingInstalled: Int = 0
    
    private var installationProcess: Process?

    private var showRealTimeTerminalOutputs: Bool
    {
        UserDefaults.standard.bool(forKey: "showRealTimeTerminalOutputOfOperations")
    }
    
    deinit
    {
        cancel()
    }
    
    @discardableResult
    func cancel() -> Bool
    {
        guard let installationProcess else {return false}
        installationProcess.terminate()
        self.installationProcess = nil
        return true
    }

    @MainActor
    func installPackage(packageToInstall: BrewPackage, using brewData: BrewDataStorage, cachedPackagesTracker: CachedPackagesTracker) async throws -> TerminalOutput
    {
        AppConstants.shared.logger.debug("Installing package \(packageToInstall.name, privacy: .auto)")

        var installationResult: TerminalOutput = .init(standardOutput: "", standardError: "")

        if packageToInstall.type == .formula
        {
            AppConstants.shared.logger.info("Package \(packageToInstall.name, privacy: .public) is Formula")

            let output: String = try await installFormula(packageToInstall).joined(separator: "")

            installationResult.standardOutput.append(output)

            installationProgress = 10

            installationStage = .finished
        }
        else
        {
            AppConstants.shared.logger.info("Package is Cask")
            try await installCask(packageToInstall)
        }

        do
        {
            try await brewData.synchronizeInstalledPackages(cachedPackagesTracker: cachedPackagesTracker)
        }
        catch let synchronizationError
        {
            AppConstants.shared.logger.error("Package isntallation function failed to synchronize packages: \(synchronizationError.localizedDescription)")
        }

        return installationResult
    }

    @MainActor
    private func installFormula(_ packageToInstall: BrewPackage) async throws -> [String]
    {
        var packageDependencies: [String] = .init()
        /// For some reason, the line `fetching [package name]` appears twice during the matching process, and the first one is a dud. Ignore that first one.
        var hasAlreadyMatchedLineAboutInstallingPackageItself: Bool = false
        var installOutput: [String] = .init()

        AppConstants.shared.logger.info("Package \(packageToInstall.name, privacy: .public) is Formula")

        let (stream, process): (AsyncStream<StreamedTerminalOutput>, Process) = shell(AppConstants.shared.brewExecutablePath, ["install", packageToInstall.name])
        installationProcess = process
        for await output in stream
        {
            switch output
            {
            case .standardOutput(let outputLine):

                AppConstants.shared.logger.debug("Package instrall line out: \(outputLine, privacy: .public)")

                if showRealTimeTerminalOutputs
                {
                    realTimeTerminalOutput.append(RealTimeTerminalLine(line: outputLine))
                }

                AppConstants.shared.logger.info("Does the line contain an element from the array? \(outputLine.containsElementFromArray(packageDependencies), privacy: .public)")

                if outputLine.contains("Fetching dependencies")
                {
                    // First, we have to get a list of all the dependencies
                    var matchedDependencies: String = try outputLine.regexMatch("(?<=\(packageToInstall.name): ).*?(.*)")
                    matchedDependencies = matchedDependencies.replacingOccurrences(of: " and", with: ",") // The last dependency is different, because it's preceded by "and" instead of "," so let's replace that "and" with "," so we can split it nicely

                    AppConstants.shared.logger.debug("Matched Dependencies: \(matchedDependencies, privacy: .auto)")

                    packageDependencies = matchedDependencies.components(separatedBy: ", ") // Make the dependency list into an array

                    AppConstants.shared.logger.debug("Package Dependencies: \(packageDependencies)")

                    AppConstants.shared.logger.debug("Will fetch \(packageDependencies.count) dependencies!")

                    numberOfPackageDependencies = packageDependencies.count // Assign the number of dependencies to the tracker for the user to see

                    installationProgress = 1
                }

                else if outputLine.contains("Installing dependencies") || outputLine.contains("Installing \(packageToInstall.name) dependency")
                {
                    AppConstants.shared.logger.info("Will install dependencies!")
                    installationStage = .installingDependencies

                    // Increment by 1 for each package that finished installing
                    numberInLineOfPackageCurrentlyBeingInstalled = numberInLineOfPackageCurrentlyBeingInstalled + 1
                    AppConstants.shared.logger.info("Installing dependency \(self.numberInLineOfPackageCurrentlyBeingInstalled) of \(packageDependencies.count)")

                    // TODO: Add a math formula for advancing the stepper
                    installationProgress = installationProgress + Double(Double(10) / (Double(3) * Double(numberOfPackageDependencies)))
                }

                else if outputLine.contains("Already downloaded") || (outputLine.contains("Fetching") && outputLine.containsElementFromArray(packageDependencies))
                {
                    AppConstants.shared.logger.info("Will fetch dependencies!")
                    installationStage = .fetchingDependencies

                    numberInLineOfPackageCurrentlyBeingFetched = numberInLineOfPackageCurrentlyBeingFetched + 1

                    AppConstants.shared.logger.info("Fetching dependency \(self.numberInLineOfPackageCurrentlyBeingFetched) of \(packageDependencies.count)")

                    installationProgress = installationProgress + Double(Double(10) / (Double(3) * (Double(numberOfPackageDependencies) * Double(5))))
                }

                else if outputLine.contains("Fetching \(packageToInstall.name)") || outputLine.contains("Installing \(packageToInstall.name)")
                {
                    if hasAlreadyMatchedLineAboutInstallingPackageItself
                    { /// Only the second line about the package being installed is valid
                        AppConstants.shared.logger.info("Will install the package itself!")
                        installationStage = .installingPackage

                        // TODO: Add a math formula for advancing the stepper
                        installationProgress = Double(installationProgress) + Double((Double(10) - Double(installationProgress)) / Double(2))

                        AppConstants.shared.logger.info("Stepper value: \(Double(Double(10) / (Double(3) * Double(self.numberOfPackageDependencies))))")
                    }
                    else
                    { /// When it appears for the first time, ignore it
                        AppConstants.shared.logger.info("Matched the dud line about the package itself being installed!")
                        hasAlreadyMatchedLineAboutInstallingPackageItself = true
                        installationProgress = Double(installationProgress) + Double((Double(10) - Double(installationProgress)) / Double(2))
                    }
                }

                installOutput.append(outputLine)

                    AppConstants.shared.logger.debug("Current installation stage: \(self.installationStage.description, privacy: .public)")

            case .standardError(let errorLine):
                AppConstants.shared.logger.error("Errored out: \(errorLine, privacy: .public)")

                if showRealTimeTerminalOutputs
                {
                    realTimeTerminalOutput.append(RealTimeTerminalLine(line: errorLine))
                }

                if errorLine.contains("a password is required")
                {
                    AppConstants.shared.logger.warning("Install requires sudo")

                    installationStage = .requiresSudoPassword
                }
            }
        }

        installationProgress = 10

        installationStage = .finished

        return installOutput
    }

    @MainActor
    func installCask(_ packageToInstall: BrewPackage) async throws
    {
        AppConstants.shared.logger.info("Package is Cask")
        AppConstants.shared.logger.debug("Installing package \(packageToInstall.name, privacy: .public)")

        let (stream, process): (AsyncStream<StreamedTerminalOutput>, Process) = shell(AppConstants.shared.brewExecutablePath, ["install", "--no-quarantine", packageToInstall.name])
        installationProcess = process
        for await output in stream
        {
            switch output
            {
            case .standardOutput(let outputLine):
                AppConstants.shared.logger.info("Output line: \(outputLine, privacy: .public)")

                if showRealTimeTerminalOutputs
                {
                   realTimeTerminalOutput.append(RealTimeTerminalLine(line: outputLine))
                }

                if outputLine.contains("Downloading")
                {
                    AppConstants.shared.logger.info("Will download Cask")

                    installationProgress = installationProgress + 2

                    installationStage = .downloadingCask
                }
                else if outputLine.contains("Installing Cask")
                {
                    AppConstants.shared.logger.info("Will install Cask")

                    installationProgress = installationProgress + 2

                    installationStage = .installingCask
                }
                else if outputLine.contains("Moving App")
                {
                    AppConstants.shared.logger.info("Moving App")

                    installationProgress = installationProgress + 2

                    installationStage = .movingCask
                }
                else if outputLine.contains("Linking binary")
                {
                    AppConstants.shared.logger.info("Linking Binary")

                    installationProgress = installationProgress + 2

                    installationStage = .linkingCaskBinary
                }
                else if outputLine.contains("Purging files")
                {
                    AppConstants.shared.logger.info("Purging old version of cask \(packageToInstall.name)")

                    installationStage = .installingCask

                    installationProgress = installationProgress + 1
                }
                else if outputLine.contains("was successfully installed")
                {
                    AppConstants.shared.logger.info("Finished installing app")

                    installationStage = .finished

                    installationProgress = 10
                }

            case .standardError(let errorLine):
                AppConstants.shared.logger.error("Line had error: \(errorLine, privacy: .public)")

                if showRealTimeTerminalOutputs
                {
                    realTimeTerminalOutput.append(RealTimeTerminalLine(line: errorLine))
                }

                if errorLine.contains("a password is required")
                {
                    AppConstants.shared.logger.warning("Install requires sudo")

                    installationStage = .requiresSudoPassword
                }
                else if errorLine.contains("there is already an App at")
                {
                    AppConstants.shared.logger.warning("The app already exists")

                    installationStage = .binaryAlreadyExists
                }
                else if errorLine.contains(/depends on hardware architecture being.+but you are running/)
                {
                    AppConstants.shared.logger.warning("Package is wrong architecture")

                    installationStage = .wrongArchitecture
                }
            }
        }
    }
}
