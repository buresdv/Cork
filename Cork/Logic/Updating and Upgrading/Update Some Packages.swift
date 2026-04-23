//
//  Update Some Packages.swift
//  Cork
//
//  Created by David Bureš - P on 02.04.2026.
//

import CorkModels
import CorkTerminalFunctions
import Defaults
import Foundation

/// The error result for updating single packages - a package that threw the error, along with the error it threw
// public typealias SinglePackageUpdatingErrorResult = (package: OutdatedPackage, error: OutdatedPackagesTracker.IndividualPackageUpdatingError)

public typealias SinglePackageUpdatingResult = Result<[TerminalOutput], OutdatedPackagesTracker.IndividualPackageUpdatingError>

extension OutdatedPackagesTracker
{
    /// Update a single package
    ///
    /// Internally, uses the `reinstall` Homebrew command
    /// - Parameter packageToUpdate: Which package to update
    /// - Returns: If successful, returns unimplemented cases for further review. If failed, returns the error case that caused the failure
    func updateSinglePackage(
        packageToUpdate: OutdatedPackage,
        updateProgressTracker: UpdateProgressTracker
    ) async -> SinglePackageUpdatingResult
    {
        let package = packageToUpdate.package

        let updateCommandArguments = {
            switch package.type
            {
            case .formula:
                return ["reinstall", package.name(withPrecision: .precise)]
            case .cask:
                return ["reinstall", "--cask", package.name(withPrecision: .precise)]
            }
        }()

        let (stream, process): (AsyncStream<TerminalOutput>, Process) = shell(appConstants.brewExecutablePath, updateCommandArguments)

        self.updateProcess = process

        var consolidatedProcessResults: [IndividialPackageUpdatingStage.StandardCases] = .init()
        var processError: IndividualPackageUpdatingError? = nil
        var processUnimplementedCases: [TerminalOutput] = .init()

        for await output in stream
        {
            updateProgressTracker.insertOutput(output)
            
            output.match(as: IndividialPackageUpdatingStage.self)
            { standardCase in
                consolidatedProcessResults.append(standardCase)
            } onErrorOutput: { errorCase in
                switch errorCase
                {
                case .postInstallStepFailed:
                    processError = .implemented(
                        failedPackage: packageToUpdate,
                        error: .postInstallStepFailed(
                            rawOutput: output.description
                        )
                    )
                case .terminalRequired:
                    processError = .implemented(
                        failedPackage: packageToUpdate,
                        error: .terminalRequired
                    )
                }
            } onUnimplementedOutput: { unimplementedCase in

                switch unimplementedCase
                {
                case .standardOutput(let standardOutput):
                    processUnimplementedCases.append(unimplementedCase)
                case .standardError(let standardError):
                    processError = .unimplemented(
                        failedPackage: packageToUpdate,
                        rawOutput: standardError
                    )
                }
            }
        }

        if let processError
        {
            return .failure(processError)
        }
        else
        {
            return .success(processUnimplementedCases)
        }
    }
}
