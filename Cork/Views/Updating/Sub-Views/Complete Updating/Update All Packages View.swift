//
//  Update All Packages View.swift
//  Cork
//
//  Created by David Bureš - P on 24.04.2026.
//

import CorkModels
import CorkTerminalFunctions
import FactoryKit
import SwiftUI
import CorkShared

struct UpdateAllPackagesView: View
{
    enum CompleteUpdatingError: Error
    {
        case mutlipleCasksFailed(TerminalOutput)
        case containsUnexpectedOutputs([TerminalOutput])
    }

    @Environment(UpdateProgressTracker.self) var updateProgressTracker: UpdateProgressTracker
    @InjectedObservable(\.outdatedPackagesTracker) var outdatedPackagesTracker: OutdatedPackagesTracker

    @Observable
    final class FullUpdateStageTracker
    {
        var currentStage: UpdateProgressTracker.UpdateProcessMatcher.StandardCases

        public init()
        {
            self.currentStage = .downloading
        }
    }

    @State private var fullUpdateStageTracker: FullUpdateStageTracker = .init()

    var body: some View
    {
        VStack(alignment: .leading)
        {
            ProgressView(updateProgressTracker.updateProgress)

            updateProgressTracker.streamedOutputsDisplay
        }
        .frame(maxWidth: .infinity)
        .task
        {
            do throws(Self.CompleteUpdatingError)
            {
                try await outdatedPackagesTracker.updatePackages(
                    updateProgressTracker: updateProgressTracker,
                    fullUpdateStageTracker: fullUpdateStageTracker
                )
                
                updateProgressTracker.updatingState = .finished
            }
            catch let completeUpdatingError
            {
                switch completeUpdatingError
                {
                case .mutlipleCasksFailed(let terminalOutput):
                    guard let extractedErrors: [UpdateProgressTracker.IndividualPackageUpdatingError] = extractFailedPackagesFromTerminalOutput(terminalOutput) else
                    {
                        AppConstants.shared.logger.error("There was supposed to be an error throws in the updater, but the parsed errors were empty")
                        
                        updateProgressTracker.updatingState = .completedWithUnexpectedOutputs(unimplementedOutputs: [terminalOutput])
                        
                        return
                    }
                    
                    updateProgressTracker.updatingState = .erroredOut(results: extractedErrors)
                    
                case .containsUnexpectedOutputs(let unexpectedOutputs):
                    updateProgressTracker.updatingState = .completedWithUnexpectedOutputs(unimplementedOutputs: unexpectedOutputs)
                }
            }
        }
    }
    
    func extractFailedPackagesFromTerminalOutput(_ terminalOutput: TerminalOutput) -> [UpdateProgressTracker.IndividualPackageUpdatingError]?
    {
        /// **Error looks like this:**
        /// Error: Problems with multiple casks:
        /// airbuddy: It seems there is already an App at \'/opt/homebrew/Caskroom/airbuddy/2.7.4,650/AirBuddy.app\'.
        /// craft: It seems there is already an App at \'/opt/homebrew/Caskroom/craft/3.2.9/Craft.app\'.
        /// xcodes-app: It seems there is already an App at \'/opt/homebrew/Caskroom/xcodes-app/4.0.2b37/Xcodes.app\'.
        
        // Step 1: Separate the text per line
        let splitErrorText: [String] = terminalOutput.description.components(separatedBy: .newlines)
        
        // Step 2: Remove whichever line contains the useless line "Error: Problems with multiple casks:" and empty lines
        let errorTextWithoutContextLine: [String] = splitErrorText.filter({ !$0.contains("Problems with multiple") && !$0.isEmpty })
        
        // Step 3: Split each line along the colon
        let splitErroredPackages: [(packageName: String, error: String)] = errorTextWithoutContextLine.map { errorLine in
            let splitLine: [String] = errorLine.components(separatedBy: ":")
            
            return (packageName: splitLine[0], error: splitLine[1])
        }
        
        let assignedErrors: [UpdateProgressTracker.IndividualPackageUpdatingError] = splitErroredPackages.compactMap { splitError in
            
            guard let packageFromTracker: OutdatedPackage = outdatedPackagesTracker.outdatedPackages.first(where: { $0.package.name(withPrecision: .precise) == splitError.packageName }) else
            {
                return .none
            }
            
            if splitError.error.contains("It seems there is already an App at")
            {
                let pathRetrievalRegex: Regex = /'(.*?)'/
                
                if let match = splitError.error.firstMatch(of: pathRetrievalRegex) {
                    return .implemented(
                        failedPackage: packageFromTracker,
                        error: .thereIsAlreadyAppAtPath(path: String(match.1))
                    )
                } else {
                    return .unimplemented(failedPackage: packageFromTracker, rawOutput: splitError.error)
                }
            }
            else
            {
                return .unimplemented(failedPackage: packageFromTracker, rawOutput: splitError.error)
            }
        }
        
        return assignedErrors
    }
}
