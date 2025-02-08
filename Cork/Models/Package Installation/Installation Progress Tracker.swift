//
//  Installation Progress Tracker.swift
//  Cork
//
//  Created by David Bureš on 22.02.2023.
//

import CorkShared
import Foundation

class InstallationProgressTracker: ObservableObject
{
    @Published var packageBeingInstalled: PackageInProgressOfBeingInstalled = .init(package: .init(name: "", type: .formula, installedOn: nil, versions: [], sizeInBytes: 0), installationStage: .downloadingCask, packageInstallationProgress: 0)

    @Published var numberOfPackageDependencies: Int = 0
    @Published var numberInLineOfPackageCurrentlyBeingFetched: Int = 0
    @Published var numberInLineOfPackageCurrentlyBeingInstalled: Int = 0

    private var showRealTimeTerminalOutputs: Bool
    {
        UserDefaults.standard.bool(forKey: "showRealTimeTerminalOutputOfOperations")
    }

    @MainActor
    func installPackage(using brewData: BrewDataStorage, cachedPackagesTracker: CachedPackagesTracker) async throws -> TerminalOutput
    {
        let package: BrewPackage = packageBeingInstalled.package

        AppConstants.shared.logger.debug("Installing package \(package.name, privacy: .auto)")

        var installationResult: TerminalOutput = .init(standardOutput: "", standardError: "")

        if package.type == .formula
        {
            AppConstants.shared.logger.info("Package \(package.name, privacy: .public) is Formula")

            let output: String = try await installFormula(using: brewData).joined(separator: "")

            installationResult.standardOutput.append(output)

            packageBeingInstalled.packageInstallationProgress = 10

            packageBeingInstalled.installationStage = .finished
        }
        else
        {
            AppConstants.shared.logger.info("Package is Cask")
            try await installCask(using: brewData)
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

    // MARK: - Formula Installation

    @MainActor
    private func installFormula(using _: BrewDataStorage) async throws -> [String]
    {
        let package: BrewPackage = packageBeingInstalled.package
        var packageDependencies: [String] = .init()
        var hasAlreadyMatchedPackage = false
        var installOutput: [String] = .init()

        AppConstants.shared.logger.info("Package \(package.name, privacy: .public) is Formula")

        for await output in shell(AppConstants.shared.brewExecutablePath, ["install", package.name])
        {
            switch output
            {
            case .standardOutput(let outputLine):
                AppConstants.shared.logger.debug("Package install line out: \(outputLine, privacy: .public)")

                if showRealTimeTerminalOutputs
                {
                    packageBeingInstalled.realTimeTerminalOutput.append(RealTimeTerminalLine(line: outputLine))
                }

                if let stage = BrewInstallationStage.matchingFormula(
                    outputLine,
                    packageName: package.name,
                    packageDependencies: packageDependencies,
                    hasAlreadyMatchedPackage: hasAlreadyMatchedPackage
                )
                {
                    switch stage
                    {
                    case .calculatingDependencies:
                        AppConstants.shared.logger.warning("Output line: \(outputLine)")

                        if var matchedDependencies = try? outputLine.regexMatch("(?<=\(package.name): ).*?(.*)")
                        {
                            AppConstants.shared.logger.info("Matched a line describing the dependencies that will be downloaded")
                            matchedDependencies = matchedDependencies.replacingOccurrences(of: " and", with: ",")
                            packageDependencies = matchedDependencies.components(separatedBy: ", ")

                            AppConstants.shared.logger.debug("Will fetch \(packageDependencies.count) dependencies!")
                            numberOfPackageDependencies = packageDependencies.count
                        }
                        packageBeingInstalled.packageInstallationProgress = 1

                    case .fetchingDependencies(let packageDependencies):
                        AppConstants.shared.logger.info("Will fetch dependencies!")
                        packageBeingInstalled.installationStage = .fetchingDependencies

                        numberInLineOfPackageCurrentlyBeingFetched = numberInLineOfPackageCurrentlyBeingFetched + 1

                        AppConstants.shared.logger.info("Fetching dependency \(self.numberInLineOfPackageCurrentlyBeingFetched) of \(packageDependencies.count)")

                        packageBeingInstalled.packageInstallationProgress = packageBeingInstalled.packageInstallationProgress + Double(Double(10) / (Double(3) * (Double(numberOfPackageDependencies) * Double(5))))

                    case .installingDependencies(let packageName):
                        AppConstants.shared.logger.info("Will install dependencies!")
                        packageBeingInstalled.installationStage = .installingDependencies
                        numberInLineOfPackageCurrentlyBeingInstalled += 1
                        packageBeingInstalled.packageInstallationProgress += Double(10) / (3 * Double(numberOfPackageDependencies))

                    case .installingPackage(let packageName, let isFirstMatch):
                        if hasAlreadyMatchedPackage
                        {
                            AppConstants.shared.logger.info("Will install the package itself!")
                            packageBeingInstalled.installationStage = .installingPackage
                        }
                        else
                        {
                            AppConstants.shared.logger.info("Matched the dud line about the package itself being installed!")
                            hasAlreadyMatchedPackage = true
                        }
                        packageBeingInstalled.packageInstallationProgress += (10 - packageBeingInstalled.packageInstallationProgress) / 2

                    case .requiresSudoPassword:
                        packageBeingInstalled.installationStage = .requiresSudoPassword

                    case .finished:
                        packageBeingInstalled.packageInstallationProgress = 10
                        packageBeingInstalled.installationStage = .finished

                    default:
                        break
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

                if let stage = BrewInstallationStage.matchingFormula(
                    errorLine,
                    packageName: package.name,
                    packageDependencies: packageDependencies,
                    hasAlreadyMatchedPackage: hasAlreadyMatchedPackage
                )
                {
                    packageBeingInstalled.installationStage = .requiresSudoPassword
                }
            }
        }

        return installOutput
    }

    // MARK: - Cask Installation

    @MainActor
    private func installCask(using _: BrewDataStorage) async throws
    {
        let package: BrewPackage = packageBeingInstalled.package

        AppConstants.shared.logger.info("Package is Cask")
        AppConstants.shared.logger.debug("Installing package \(package.name, privacy: .public)")

        for await output in shell(AppConstants.shared.brewExecutablePath, ["install", "--no-quarantine", package.name])
        {
            switch output
            {
            case .standardOutput(let outputLine):
                AppConstants.shared.logger.info("Output line: \(outputLine, privacy: .public)")

                if showRealTimeTerminalOutputs
                {
                    packageBeingInstalled.realTimeTerminalOutput.append(RealTimeTerminalLine(line: outputLine))
                }

                if let stage = BrewInstallationStage.matchingCask(outputLine)
                {
                    switch stage
                    {
                    case .downloadingCask:
                        AppConstants.shared.logger.info("Will download Cask")
                        packageBeingInstalled.installationStage = .downloadingCask
                        packageBeingInstalled.packageInstallationProgress += 2

                    case .installingCask:
                        AppConstants.shared.logger.info("Will install Cask")
                        packageBeingInstalled.installationStage = .installingCask
                        packageBeingInstalled.packageInstallationProgress += 2

                    case .movingCask:
                        AppConstants.shared.logger.info("Moving App")
                        packageBeingInstalled.installationStage = .movingCask
                        packageBeingInstalled.packageInstallationProgress += 2

                    case .linkingCaskBinary:
                        AppConstants.shared.logger.info("Linking Binary")
                        packageBeingInstalled.installationStage = .linkingCaskBinary
                        packageBeingInstalled.packageInstallationProgress += 2

                    case .finished:
                        AppConstants.shared.logger.info("Finished installing app")
                        packageBeingInstalled.installationStage = .finished
                        packageBeingInstalled.packageInstallationProgress = 10

                    default:
                        break
                    }
                }

            case .standardError(let errorLine):
                AppConstants.shared.logger.error("Line had error: \(errorLine, privacy: .public)")

                if showRealTimeTerminalOutputs
                {
                    packageBeingInstalled.realTimeTerminalOutput.append(RealTimeTerminalLine(line: errorLine))
                }

                if let stage = BrewInstallationStage.matchingCask(errorLine)
                {
                    packageBeingInstalled.installationStage = .terminatedUnexpectedly
                }
            }
        }
    }
}

// MARK: - Match Conditions

private enum MatchCondition
{
    case simple(String)
    case complex((String) -> Bool)
}

private protocol InstallationStage
{
    var matchConditions: [MatchCondition] { get }
}

// MARK: - Installation Stage Enum

enum BrewInstallationStage: InstallationStage
{
    // Formula-specific stages
    case calculatingDependencies
    case fetchingDependencies(packageDependencies: [String])
    case installingDependencies(packageName: String)
    case installingPackage(packageName: String, isFirstMatch: Bool)

    // Cask-specific stages
    case downloadingCask
    case installingCask
    case movingCask
    case linkingCaskBinary

    // Common stages
    case requiresSudoPassword
    case finished
    case binaryAlreadyExists
    case wrongArchitecture

    fileprivate var matchConditions: [MatchCondition]
    {
        switch self
        {
        case .calculatingDependencies:
            return [
                .simple("Fetching dependencies")
            ]

        case .fetchingDependencies(let dependencies):
            return [
                .simple("Already downloaded"),
                .complex
                { line in
                    line.contains("Fetching") && line.containsElementFromArray(dependencies)
                }
            ]

        case .installingDependencies(let packageName):
            return [
                .complex
                { line in
                    line.contains("Installing dependencies") || line.contains("Installing \(packageName) dependency")
                }
            ]

        case .installingPackage(let packageName, let isFirstMatch):
            return [
                .simple("Fetching \(packageName)"),
                .simple("Installing \(packageName)")
            ]

        case .downloadingCask:
            return [
                .simple("==> Downloading")
            ]

        case .installingCask:
            return [
                .simple("==> Installing Cask"),
                .simple("==> Purging files")
            ]

        case .movingCask:
            return [
                .simple("==> Moving App")
            ]

        case .linkingCaskBinary:
            return [
                .simple("==> Linking binary")
            ]

        case .requiresSudoPassword:
            return [
                .simple("password is required")
            ]

        case .finished:
            return [
                .simple("was successfully installed")
            ]

        case .binaryAlreadyExists:
            return [
                .simple("there is already an App at")
            ]

        case .wrongArchitecture:
            return [
                .complex
                { line in
                    line.contains("depends on hardware architecture being") &&
                        line.contains("but you are running")
                }
            ]
        }
    }

    var description: String
    {
        switch self
        {
        case .calculatingDependencies:
            return "Calculating dependencies"
        case .fetchingDependencies:
            return "Fetching Dependencies"
        case .installingDependencies:
            return "Installing Dependencies"
        case .installingPackage:
            return "Installing Package"
        case .downloadingCask:
            return "Downloading Cask"
        case .installingCask:
            return "Installing Cask"
        case .movingCask:
            return "Moving Cask"
        case .linkingCaskBinary:
            return "Linking Binary"
        case .requiresSudoPassword:
            return "Requires Sudo Password"
        case .finished:
            return "Finished"
        case .binaryAlreadyExists:
            return "Binary Already Exists"
        case .wrongArchitecture:
            return "Wrong Architecture"
        }
    }

    static func matchingFormula(_ output: String, packageName: String, packageDependencies: [String], hasAlreadyMatchedPackage: Bool) -> Self?
    {
        let allCases: [Self] = [
            .fetchingDependencies(packageDependencies: packageDependencies),
            .installingDependencies(packageName: packageName),
            .installingPackage(packageName: packageName, isFirstMatch: !hasAlreadyMatchedPackage),
            .requiresSudoPassword,
            .finished
        ]

        return matchStage(output, from: allCases)
    }

    static func matchingCask(_ output: String) -> Self?
    {
        let allCases: [Self] = [
            .downloadingCask,
            .installingCask,
            .movingCask,
            .linkingCaskBinary,
            .requiresSudoPassword,
            .binaryAlreadyExists,
            .wrongArchitecture,
            .finished
        ]

        return matchStage(output, from: allCases)
    }

    private static func matchStage(_ output: String, from cases: [Self]) -> Self?
    {
        for stage in cases
        {
            for condition in stage.matchConditions
            {
                switch condition
                {
                case .simple(let pattern):
                    if output.contains(pattern)
                    {
                        return stage
                    }
                case .complex(let matcher):
                    if matcher(output)
                    {
                        return stage
                    }
                }
            }
        }

        return nil
    }
}
