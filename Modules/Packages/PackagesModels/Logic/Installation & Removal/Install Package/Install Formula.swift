//
//  Install Formula.swift
//  Cork
//
//  Created by David Bureš on 28.04.2026.
//

import CorkShared
import CorkTerminalFunctions
import Foundation

extension InstallationProgressTracker
{
    @MainActor
    func installFormula(
        _ formulaToInstall: MinimalHomebrewPackage
    ) async throws(InstallationError)
    {
        AppConstants.shared.logger.info("Package is Formula")
        AppConstants.shared.logger.debug("Installing package \(formulaToInstall.name(withPrecision: .precise), privacy: .public)")

        var packageDependencies: [String] = .init()

        let (stream, process): (AsyncStream<TerminalOutput>, Process) = shell(AppConstants.shared.brewExecutablePath, ["install", formulaToInstall.name(withPrecision: .precise)])
        installationProcess = process

        var consolidatedUnimplementedOutput: [TerminalOutput] = .init()
        var installError: InstallationError.ImplementedError.FormulaInstallError?
        var hasAlreadyMatchedLineAboutInstallingPackageItself: Bool = false
        var installOutput: [String] = .init()

        for await output in stream
        {
            switch output
            {
            case .standardOutput(let outputLine):

                AppConstants.shared.logger.debug("Package instrall line out: \(outputLine, privacy: .public)")

                AppConstants.shared.logger.info("Does the line contain an element from the array? \(outputLine.containsElementFromArray(packageDependencies ?? .init()), privacy: .public)")

                if outputLine.contains(/Would install \d dependencies for/)
                {
                    AppConstants.shared.logger.info("Will get the dependencies!")
                    
                    let matchedDependencies: [String] = outputLine.matches(of: /(?m)^[^\s]+$/).map{ String($0.output) }
                    
                    AppConstants.shared.logger.info("Got these dependencies: \(matchedDependencies)")
                    
                    packageDependencies = matchedDependencies
                    
                    self.numberOfPackageDependencies = packageDependencies.count
                    
                    self.installProgress.completedUnitCount = 1
                }
                else if outputLine.contains("Installing dependencies") || outputLine.contains("Installing \(formulaToInstall.name(withPrecision: .precise)) dependency")
                {
                    AppConstants.shared.logger.info("Will install dependencies!")
                    self.installStage = .formula(.installingDependencies(dependencyName: "", dependencyNumber: self.numberInLineOfPackageCurrentlyBeingInstalled + 1, totalNumberOfDependencies: packageDependencies.count))

                    // Increment by 1 for each package that finished installing
                    self.numberInLineOfPackageCurrentlyBeingInstalled = self.numberInLineOfPackageCurrentlyBeingInstalled + 1
                    AppConstants.shared.logger.info("Installing dependency \(self.numberInLineOfPackageCurrentlyBeingInstalled) of \(packageDependencies.count)")

                    // TODO: Add a math formula for advancing the stepper
                    self.installProgress.completedUnitCount = self.installProgress.completedUnitCount + Int64(Double(10) / (Double(3) * Double(self.numberOfPackageDependencies)))
                }

                else if outputLine.contains("Already downloaded") || (outputLine.contains("Fetching") && outputLine.containsElementFromArray(packageDependencies ?? .empty))
                {
                    AppConstants.shared.logger.info("Will fetch dependencies!")
                    self.installStage = .formula(.downloadingDependencies(dependencyName: ""))

                    self.numberInLineOfPackageCurrentlyBeingFetched = self.numberInLineOfPackageCurrentlyBeingFetched + 1

                    AppConstants.shared.logger.info("Fetching dependency \(self.numberInLineOfPackageCurrentlyBeingFetched) of \(packageDependencies.count)")

                    self.installProgress.completedUnitCount = self.installProgress.completedUnitCount + Int64(Double(10) / (Double(3) * (Double(self.numberOfPackageDependencies) * Double(5))))
                }

                else if outputLine.contains("Fetching \(formulaToInstall.name(withPrecision: .precise))") || outputLine.contains("Installing \(formulaToInstall.name(withPrecision: .precise))")
                {
                    if hasAlreadyMatchedLineAboutInstallingPackageItself
                    { /// Only the second line about the package being installed is valid
                        AppConstants.shared.logger.info("Will install the package itself!")
                        self.installStage = .formula(.installingPackage(package: formulaToInstall))

                        // TODO: Add a math formula for advancing the stepper
                        self.installProgress.completedUnitCount = self.installProgress.completedUnitCount + Int64((Double(10) - Double(self.installProgress.completedUnitCount)) / Double(2))

                        AppConstants.shared.logger.info("Stepper value: \(Double(Double(10) / (Double(3) * Double(self.numberOfPackageDependencies))))")
                    }
                    else
                    { /// When it appears for the first time, ignore it
                        AppConstants.shared.logger.info("Matched the dud line about the package itself being installed!")
                        hasAlreadyMatchedLineAboutInstallingPackageItself = true
                        self.installProgress.completedUnitCount = self.installProgress.completedUnitCount + Int64((Double(10) - Double(self.installProgress.completedUnitCount)) / Double(2))
                    }
                }

                installOutput.append(outputLine)

                AppConstants.shared.logger.debug("Current installation stage: \(String(describing: self.installStage))")

            case .standardError(let errorLine):
                AppConstants.shared.logger.error("Errored out: \(errorLine, privacy: .public)")

                if errorLine.contains("a password is required")
                {
                    AppConstants.shared.logger.warning("Install requires sudo")

                    installError = .implemented(.requiresSudoPassword)
                }
            }

            print("Install errors: \(String(describing: installError))")

            if let installError
            {
                print("Install process will throw error: \(installError)")

                throw .implemented(.couldNotInstallFormula(installError))
            }

            if !consolidatedUnimplementedOutput.isEmpty
            {
                throw .implemented(.couldNotInstallFormula(.unimplelented(rawOutput: consolidatedUnimplementedOutput)))
            }
        }
    }
}
