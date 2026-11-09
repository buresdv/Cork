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
import CorkShared

/// The error result for updating single packages - a package that threw the error, along with the error it threw
// public typealias SinglePackageUpdatingErrorResult = (package: OutdatedPackage, error: OutdatedPackagesTracker.IndividualPackageUpdatingError)

public typealias SinglePackageUpdatingResult = Result<[TerminalOutput], UpdateProgressTracker.IndividualPackageUpdatingError>

extension OutdatedPackagesTracker
{
    func updateSomePackages(
        packagesToUpdate: [OutdatedPackage],
        updateProgressTracker: UpdateProgressTracker,
        // updateStageProgress: Progress
    ) async {
        let formulaeToUpdate: [OutdatedPackage] = packagesToUpdate.filter({ $0.package.type == .formula })
        
        let casksToUpdate: [OutdatedPackage] = packagesToUpdate.filter({ $0.package.type == .cask })
        
        appConstants.logger.info("""
            Will selectively update:
            \(formulaeToUpdate.count) formulae: \(formulaeToUpdate.map({ $0.package.name(withPrecision: .precise)} ))
            \(casksToUpdate.count) casks: \(casksToUpdate.map({ $0.package.name(withPrecision: .precise)} ))
            """)
        
        if !formulaeToUpdate.isEmpty
        {
            await updateFormulae(
                formulaeToUpdate: formulaeToUpdate,
                totalPackagesSelectedForSelectiveUpdating: Double(packagesToUpdate.count),
                updateProgressTracker: updateProgressTracker
            )
        }
        else
        {
            appConstants.logger.info("There are no Formulae to selectively update")
        }
        
        if !casksToUpdate.isEmpty
        {
            await updateCasks(
                casksToUpdate: casksToUpdate,
                totalPackagesSelectedForSelectiveUpdating: Double(packagesToUpdate.count),
                updateProgressTracker: updateProgressTracker
            )
        }
        else {
            appConstants.logger.info("There are no Casks to selectively update")
        }
    }
    
    // MARK: - Formulae updating
    
    private func updateFormulae(
        formulaeToUpdate: [OutdatedPackage],
        totalPackagesSelectedForSelectiveUpdating: Double,
        updateProgressTracker: UpdateProgressTracker
    ) async {
        let percentageOfTotalNumberOfPackagesSelectedToBeUpdated: Double = Double( (Double(formulaeToUpdate.count) / totalPackagesSelectedForSelectiveUpdating) * 100 )
        
        appConstants.logger.debug("Percentage for formulae: \(percentageOfTotalNumberOfPackagesSelectedToBeUpdated)")
        
        let formulaePartProgressTracker: Progress = .init(
            parent: updateProgressTracker.updateProgress,
            percentageOfParentToTakeUp: percentageOfTotalNumberOfPackagesSelectedToBeUpdated,
            totalItemsOfThisProgress: formulaeToUpdate.count
        )
        
        formulaePartProgressTracker.increment(byPercentage: 100)
    }
    
    private func updateCasks(
        casksToUpdate: [OutdatedPackage],
        totalPackagesSelectedForSelectiveUpdating: Double,
        updateProgressTracker: UpdateProgressTracker
    ) async {
        let percentageOfTotalNumberOfPackagesSelectedToBeUpdated: Double = Double( (Double(casksToUpdate.count) / totalPackagesSelectedForSelectiveUpdating) * 100 )
        
        appConstants.logger.debug("Percentage for casks: \(percentageOfTotalNumberOfPackagesSelectedToBeUpdated)")
        
        let casksPartProgressTracker: Progress = .init(
            parent: updateProgressTracker.updateProgress,
            percentageOfParentToTakeUp: percentageOfTotalNumberOfPackagesSelectedToBeUpdated,
            totalItemsOfThisProgress: casksToUpdate.count
        )
        
        casksPartProgressTracker.increment(byPercentage: 100)
    }
}

extension OutdatedPackagesTracker
{
    /// Update a single package
    ///
    /// Internally, uses the `reinstall` Homebrew command
    /// - Parameter packageToUpdate: Which package to update
    /// - Returns: If successful, returns unimplemented cases for further review. If failed, returns the error case that caused the failure
    func updateSinglePackage(
        packageToUpdate: OutdatedPackage,
        updateProgressTracker: UpdateProgressTracker,
        updateStageProgress: Progress
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

        let (stream, process): (AsyncStream<TerminalOutput>, Process) = await shell(appConstants.brewExecutablePath, updateCommandArguments)

        self.updateProcess = process

        var consolidatedProcessResults: [UpdateProgressTracker.IndividialPackageUpdatingStage.StandardCases] = .init()
        var processError: UpdateProgressTracker.IndividualPackageUpdatingError? = nil
        var processUnimplementedCases: [TerminalOutput] = .init()

        for await output in stream
        {
            updateProgressTracker.insertOutput(output)
            
            output.match(as: UpdateProgressTracker.IndividialPackageUpdatingStage.self)
            { standardCase in
                AppConstants.shared.logger.debug("Matched update standard case: \(standardCase.description)")
                
                consolidatedProcessResults.append(standardCase)
                
                updateStageProgress.increment(bySetNumber: 1)
                
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
                AppConstants.shared.logger.debug("Matched update unimplemented case: \(unimplementedCase.description)")
                
                switch unimplementedCase
                {
                case .standardOutput(let standardOutput):
                    processUnimplementedCases.append(unimplementedCase)
                case .standardError(let standardError):
                    processError = .unimplemented(
                        failedPackage: packageToUpdate,
                        rawOutput: standardError.rawOutput
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
