//
//  Install Formula.swift
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
    private func installFormula() async throws(InstallationError.ImplementedError.FormulaInstallError)
    {
        let package: BrewPackage = packageBeingInstalled.package
        var packageDependencies: [String] = .init()
        /// For some reason, the line `fetching [package name]` appears twice during the matching process, and the first one is a dud. Ignore that first one.
        var hasAlreadyMatchedLineAboutInstallingPackageItself: Bool = false
        var installOutput: [String] = .init()

        AppConstants.shared.logger.info("Package \(package.name(withPrecision: .precise), privacy: .public) is Formula")

        let (stream, process): (AsyncStream<TerminalOutput>, Process) = shell(AppConstants.shared.brewExecutablePath, ["install", package.name(withPrecision: .precise)])
        installationProcess = process
        for await output in stream
        {
            self.insertOutput(output)
            
            output.match(as: FormulaInstallMatcher.self)
            { standardCase in
                switch standardCase
                {
                case .findingDependencies:
                    // First, we have to get a list of all the dependencies
                    var matchedDependencies: String = try? output.description.regexMatch("(?<=\(package.name(withPrecision: .precise)): ).*?(.*)")
                    matchedDependencies = matchedDependencies.replacingOccurrences(of: " and", with: ",") // The last dependency is different, because it's preceded by "and" instead of "," so let's replace that "and" with "," so we can split it nicely

                    AppConstants.shared.logger.debug("Matched Dependencies: \(matchedDependencies, privacy: .auto)")

                    packageDependencies = matchedDependencies.components(separatedBy: ", ") // Make the dependency list into an array

                    AppConstants.shared.logger.debug("Package Dependencies: \(packageDependencies)")

                    AppConstants.shared.logger.debug("Will fetch \(packageDependencies.count) dependencies!")

                    numberOfPackageDependencies = packageDependencies.count // Assign the number of dependencies to the tracker for the user to see

                    packageBeingInstalled.packageInstallationProgress = 1
                case .downloadingDependencies:
                    AppConstants.shared.logger.info("Will fetch dependencies!")
                    packageBeingInstalled.installationStage = .fetchingDependencies

                    numberInLineOfPackageCurrentlyBeingFetched = numberInLineOfPackageCurrentlyBeingFetched + 1

                    AppConstants.shared.logger.info("Fetching dependency \(self.numberInLineOfPackageCurrentlyBeingFetched) of \(packageDependencies.count)")

                    packageBeingInstalled.packageInstallationProgress = packageBeingInstalled.packageInstallationProgress + Double(Double(10) / (Double(3) * (Double(numberOfPackageDependencies) * Double(5))))
                case .installingDependencies:
                    AppConstants.shared.logger.info("Will install dependencies!")
                    packageBeingInstalled.installationStage = .installingDependencies

                    // Increment by 1 for each package that finished installing
                    numberInLineOfPackageCurrentlyBeingInstalled = numberInLineOfPackageCurrentlyBeingInstalled + 1
                    AppConstants.shared.logger.info("Installing dependency \(self.numberInLineOfPackageCurrentlyBeingInstalled) of \(packageDependencies.count)")

                    // TODO: Add a math formula for advancing the stepper
                    packageBeingInstalled.packageInstallationProgress = packageBeingInstalled.packageInstallationProgress + Double(Double(10) / (Double(3) * Double(numberOfPackageDependencies)))
                case .downloadingPackage:
                    <#code#>
                case .installingPackage:
                    <#code#>
                }
            } onErrorOutput: { errorCase in
                <#code#>
            } onUnimplementedOutput: { unimplementedCase in
                <#code#>
            }

            
            switch output
            {
            case .standardOutput(let outputLine):

                AppConstants.shared.logger.debug("Package instrall line out: \(outputLine, privacy: .public)")

                AppConstants.shared.logger.info("Does the line contain an element from the array? \(outputLine.containsElementFromArray(packageDependencies), privacy: .public)")

                if outputLine.contains("Fetching dependencies")
                {
                    
                }

                else if outputLine.contains("Installing dependencies") || outputLine.contains("Installing \(package.name(withPrecision: .precise)) dependency")
                {
                    
                }

                else if outputLine.contains("Already downloaded") || (outputLine.contains("Fetching") && outputLine.containsElementFromArray(packageDependencies))
                {
                    AppConstants.shared.logger.info("Will fetch dependencies!")
                    packageBeingInstalled.installationStage = .fetchingDependencies

                    numberInLineOfPackageCurrentlyBeingFetched = numberInLineOfPackageCurrentlyBeingFetched + 1

                    AppConstants.shared.logger.info("Fetching dependency \(self.numberInLineOfPackageCurrentlyBeingFetched) of \(packageDependencies.count)")

                    packageBeingInstalled.packageInstallationProgress = packageBeingInstalled.packageInstallationProgress + Double(Double(10) / (Double(3) * (Double(numberOfPackageDependencies) * Double(5))))
                }

                else if outputLine.contains("Fetching \(package.name(withPrecision: .precise))") || outputLine.contains("Installing \(package.name(withPrecision: .precise))")
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
                    packageBeingInstalled.realTimeTerminalOutput.append(RealTimeTerminalLine(line: output))
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
    }
}
