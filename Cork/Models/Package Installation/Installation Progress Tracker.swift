//
//  Installation Progress Tracker.swift
//  Cork
//
//  Created by David Bureš on 22.02.2023.
//

import Foundation
import CorkShared
import CorkModels
import CorkTerminalFunctions

@Observable
class InstallationProgressTracker
{
    var packageBeingInstalled: PackageInProgressOfBeingInstalled = .init(package: .init(name: "", type: .formula, installedOn: nil, versions: [], url: nil, sizeInBytes: 0, downloadCount: nil), installationStage: .downloadingCask, packageInstallationProgress: 0)

    var numberOfPackageDependencies: Int = 0
    var numberInLineOfPackageCurrentlyBeingFetched: Int = 0
    var numberInLineOfPackageCurrentlyBeingInstalled: Int = 0
    
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
    func installPackage(using brewPackagesTracker: BrewPackagesTracker, cachedDownloadsTracker: CachedDownloadsTracker) async throws -> TerminalOutput
    {
        let package: BrewPackage = packageBeingInstalled.package

        AppConstants.shared.logger.debug("Installing package \(package.getPackageName(withPrecision: .precise), privacy: .auto)")

        var installationResult: TerminalOutput = .init(standardOutput: "", standardError: "")

        if package.type == .formula
        {
            AppConstants.shared.logger.info("Package \(package.getPackageName(withPrecision: .precise), privacy: .public) is Formula")

            let output: String = try await installFormula(using: brewPackagesTracker).joined(separator: "")

            installationResult.standardOutput.append(output)

            packageBeingInstalled.packageInstallationProgress = 10

            packageBeingInstalled.installationStage = .finished
        }
        else
        {
            AppConstants.shared.logger.info("Package is Cask")
            try await installCask(using: brewPackagesTracker)
        }

        do
        {
            try await brewPackagesTracker.synchronizeInstalledPackages(cachedDownloadsTracker: cachedDownloadsTracker)
        }
        catch let synchronizationError
        {
            AppConstants.shared.logger.error("Package isntallation function failed to synchronize packages: \(synchronizationError.localizedDescription)")
        }

        return installationResult
    }

    @MainActor
    private func installFormula(using _: BrewPackagesTracker) async throws -> [String]
    {
        let package: BrewPackage = packageBeingInstalled.package
        var packageDependencies: [String] = .init()
        /// For some reason, the line `fetching [package name]` appears twice during the matching process, and the first one is a dud. Ignore that first one.
        var hasAlreadyMatchedLineAboutInstallingPackageItself: Bool = false
        var installOutput: [String] = .init()

        AppConstants.shared.logger.info("Package \(package.getPackageName(withPrecision: .precise), privacy: .public) is Formula")

        let (stream, process): (AsyncStream<StreamedTerminalOutput>, Process) = shell(AppConstants.shared.brewExecutablePath, ["install", package.getPackageName(withPrecision: .precise)])
        installationProcess = process
        for await output in stream
        {
            switch output
            {
            case .standardOutput(let outputLine):

                AppConstants.shared.logger.debug("Package instrall line out: \(outputLine, privacy: .public)")

                if showRealTimeTerminalOutputs
                {
                    packageBeingInstalled.realTimeTerminalOutput.append(RealTimeTerminalLine(line: outputLine))
                }

                AppConstants.shared.logger.info("Does the line contain an element from the array? \(outputLine.containsElementFromArray(packageDependencies), privacy: .public)")

                if outputLine.contains("Fetching dependencies")
                {
                    // First, we have to get a list of all the dependencies
                    var matchedDependencies: String = try outputLine.regexMatch("(?<=\(package.getPackageName(withPrecision: .precise)): ).*?(.*)")
                    matchedDependencies = matchedDependencies.replacingOccurrences(of: " and", with: ",") // The last dependency is different, because it's preceded by "and" instead of "," so let's replace that "and" with "," so we can split it nicely

                    AppConstants.shared.logger.debug("Matched Dependencies: \(matchedDependencies, privacy: .auto)")

                    packageDependencies = matchedDependencies.components(separatedBy: ", ") // Make the dependency list into an array

                    AppConstants.shared.logger.debug("Package Dependencies: \(packageDependencies)")

                    AppConstants.shared.logger.debug("Will fetch \(packageDependencies.count) dependencies!")

                    numberOfPackageDependencies = packageDependencies.count // Assign the number of dependencies to the tracker for the user to see

                    packageBeingInstalled.packageInstallationProgress = 1
                }

                else if outputLine.contains("Installing dependencies") || outputLine.contains("Installing \(package.getPackageName(withPrecision: .precise)) dependency")
                {
                    AppConstants.shared.logger.info("Will install dependencies!")
                    packageBeingInstalled.installationStage = .installingDependencies

                    // Increment by 1 for each package that finished installing
                    numberInLineOfPackageCurrentlyBeingInstalled = numberInLineOfPackageCurrentlyBeingInstalled + 1
                    AppConstants.shared.logger.info("Installing dependency \(self.numberInLineOfPackageCurrentlyBeingInstalled) of \(packageDependencies.count)")

                    // TODO: Add a math formula for advancing the stepper
                    packageBeingInstalled.packageInstallationProgress = packageBeingInstalled.packageInstallationProgress + Double(Double(10) / (Double(3) * Double(numberOfPackageDependencies)))
                }

                else if outputLine.contains("Already downloaded") || (outputLine.contains("Fetching") && outputLine.containsElementFromArray(packageDependencies))
                {
                    AppConstants.shared.logger.info("Will fetch dependencies!")
                    packageBeingInstalled.installationStage = .fetchingDependencies

                    numberInLineOfPackageCurrentlyBeingFetched = numberInLineOfPackageCurrentlyBeingFetched + 1

                    AppConstants.shared.logger.info("Fetching dependency \(self.numberInLineOfPackageCurrentlyBeingFetched) of \(packageDependencies.count)")

                    packageBeingInstalled.packageInstallationProgress = packageBeingInstalled.packageInstallationProgress + Double(Double(10) / (Double(3) * (Double(numberOfPackageDependencies) * Double(5))))
                }

                else if outputLine.contains("Fetching \(package.getPackageName(withPrecision: .precise))") || outputLine.contains("Installing \(package.getPackageName(withPrecision: .precise))")
                {
                    if hasAlreadyMatchedLineAboutInstallingPackageItself
                    { /// Only the second line about the package being installed is valid
                        AppConstants.shared.logger.info("Will install the package itself!")
                        packageBeingInstalled.installationStage = .installingPackage

                        // TODO: Add a math formula for advancing the stepper
                        packageBeingInstalled.packageInstallationProgress = Double(packageBeingInstalled.packageInstallationProgress) + Double((Double(10) - Double(packageBeingInstalled.packageInstallationProgress)) / Double(2))

                        AppConstants.shared.logger.info("Stepper value: \(Double(Double(10) / (Double(3) * Double(self.numberOfPackageDependencies))))")
                    }
                    else
                    { /// When it appears for the first time, ignore it
                        AppConstants.shared.logger.info("Matched the dud line about the package itself being installed!")
                        hasAlreadyMatchedLineAboutInstallingPackageItself = true
                        packageBeingInstalled.packageInstallationProgress = Double(packageBeingInstalled.packageInstallationProgress) + Double((Double(10) - Double(packageBeingInstalled.packageInstallationProgress)) / Double(2))
                    }
                }

                installOutput.append(outputLine)

                    AppConstants.shared.logger.debug("Current installation stage: \(self.packageBeingInstalled.installationStage.description, privacy: .public)")

            case .standardError(let errorLine):
                AppConstants.shared.logger.error("Errored out: \(errorLine, privacy: .public)")

                if showRealTimeTerminalOutputs
                {
                    packageBeingInstalled.realTimeTerminalOutput.append(RealTimeTerminalLine(line: errorLine))
                }

                if errorLine.contains("a password is required")
                {
                    AppConstants.shared.logger.warning("Install requires sudo")

                    packageBeingInstalled.installationStage = .requiresSudoPassword
                }
            }
        }

        packageBeingInstalled.packageInstallationProgress = 10

        packageBeingInstalled.installationStage = .finished

        return installOutput
    }

    @MainActor
    func installCask(using _: BrewPackagesTracker) async throws
    {
        let package: BrewPackage = packageBeingInstalled.package

        AppConstants.shared.logger.info("Package is Cask")
        AppConstants.shared.logger.debug("Installing package \(package.getPackageName(withPrecision: .precise), privacy: .public)")

        let (stream, process): (AsyncStream<StreamedTerminalOutput>, Process) = shell(AppConstants.shared.brewExecutablePath, ["install", package.getPackageName(withPrecision: .precise)])
        installationProcess = process
        for await output in stream
        {
            switch output
            {
            case .standardOutput(let outputLine):
                AppConstants.shared.logger.info("Output line: \(outputLine, privacy: .public)")

                if showRealTimeTerminalOutputs
                {
                    packageBeingInstalled.realTimeTerminalOutput.append(RealTimeTerminalLine(line: outputLine))
                }

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
                    AppConstants.shared.logger.info("Purging old version of cask \(package.getPackageName(withPrecision: .precise))")

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

                if showRealTimeTerminalOutputs
                {
                    packageBeingInstalled.realTimeTerminalOutput.append(RealTimeTerminalLine(line: errorLine))
                }

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
