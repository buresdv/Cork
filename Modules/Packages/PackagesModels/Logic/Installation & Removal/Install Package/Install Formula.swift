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

        let ignoredOutputs: [any RegexComponent] = [
            /Would install \d formula/
        ]

        for await output in stream
        {
            // Check if the line isn't ignorable
            guard !output.description.containsElementFromArray(ignoredOutputs)
            else
            {
                AppConstants.shared.logger.info("Hit ignored output: \(output.description)")
                continue
            }

            self.insertOutput(output)

            switch output
            {
            case .standardOutput(let outputLine):

                AppConstants.shared.logger.debug("Package instrall line out: \(outputLine, privacy: .public)")

                AppConstants.shared.logger.info("Does the line contain an element from the array? \(outputLine.containsElementFromArray(packageDependencies), privacy: .public)")

                if outputLine.contains(/Would install \d dependencies for/)
                {
                    AppConstants.shared.logger.info("Will get the dependencies!")

                    let matchedDependencies: [String] = outputLine.matches(of: /(?m)^[^\s]+$/).map { String($0.output) }

                    AppConstants.shared.logger.info("Got these dependencies: \(matchedDependencies)")

                    packageDependencies = matchedDependencies

                    self.numberOfPackageDependencies = packageDependencies.count

                    self.installProgress.completedUnitCount = 1
                }
                else if outputLine.contains("Installing dependencies") || outputLine.contains("Installing \(formulaToInstall.name(withPrecision: .precise)) dependency") || outputLine.contains("Pouring") && outputLine.containsElementFromArray(packageDependencies)
                {
                    AppConstants.shared.logger.info("Will install dependencies!")
                    self.installStage = .formula(.installingDependencies(dependencyName: "", dependencyNumber: self.numberInLineOfPackageCurrentlyBeingInstalled + 1, totalNumberOfDependencies: packageDependencies.count))

                    // Increment by 1 for each package that finished installing
                    self.numberInLineOfPackageCurrentlyBeingInstalled = self.numberInLineOfPackageCurrentlyBeingInstalled + 1
                    AppConstants.shared.logger.info("Installing dependency \(self.numberInLineOfPackageCurrentlyBeingInstalled) of \(packageDependencies.count)")

                    // TODO: Add a math formula for advancing the stepper
                    self.installProgress.increment(byPercentage: 4)
                }

                else if outputLine.contains("Already downloaded") || (outputLine.contains("Fetching") && outputLine.containsElementFromArray(packageDependencies))
                {
                    guard !packageDependencies.isEmpty
                    else
                    {
                        AppConstants.shared.logger.warning("Falsely jumped into dependency install branch - inspect error")

                        return
                    }
                    AppConstants.shared.logger.info("Will fetch dependencies!")
                    self.installStage = .formula(.downloadingDependencies(dependencyName: ""))

                    self.numberInLineOfPackageCurrentlyBeingFetched = self.numberInLineOfPackageCurrentlyBeingFetched + 1

                    AppConstants.shared.logger.info("Fetching dependency \(self.numberInLineOfPackageCurrentlyBeingFetched) of \(packageDependencies.count)")

                    self.installProgress.increment(byPercentage: 4)
                }

                else if outputLine.contains("Fetching \(formulaToInstall.name(withPrecision: .precise))") || outputLine.contains("Installing \(formulaToInstall.name(withPrecision: .precise))") || outputLine.contains("Pouring") && outputLine.contains(formulaToInstall.name(withPrecision: .general))
                {
                    AppConstants.shared.logger.info("Will install package itself!")

                    self.installStage = .formula(.installingPackage(package: formulaToInstall))

                    // TODO: Add a math formula for advancing the stepper
                    self.installProgress.set(toPercentage: 90)
                }
                else
                {
                    consolidatedUnimplementedOutput.append(output)
                }

                switch self.installStage
                {
                case .formula(let standardCase):
                    self.installProgress.setText(to: .belowBar(standardCase.stageDescription))
                case .cask(_):
                    return
                }

                AppConstants.shared.logger.debug("Current installation stage: \(String(describing: self.installStage))")

            case .standardError(let errorLine):
                AppConstants.shared.logger.error("Errored out: \(errorLine, privacy: .public)")

                if errorLine.contains("a password is required")
                {
                    AppConstants.shared.logger.warning("Install requires sudo")

                    installError = .implemented(.requiresSudoPassword)
                }
            }
        }

        AppConstants.shared.logger.info("""
        Installer result:
        - Fatal install errors: \(installError)
        - Consolidated unimplemented outputs: \(consolidatedUnimplementedOutput)
        """)

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
