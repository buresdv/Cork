//
//  Upgrade Packages.swift
//  Cork
//
//  Created by David Bureš on 04.07.2022.
//

import CorkShared
import CorkTerminalFunctions
import Defaults
import Foundation
import SwiftUI
import CorkModels
import BetterProgress

extension OutdatedPackagesTracker
{
    @MainActor
    func updatePackages(
        updateProgressTracker: UpdateProgressTracker,
        fullUpdateStageTracker: UpdateAllPackagesView.FullUpdateStageTracker
    ) async throws(UpdateAllPackagesView.CompleteUpdatingError)
    {
        let includeGreedyPackages: Bool = Defaults[.includeGreedyOutdatedPackages]
        
        let totalCases: Int = UpdateProgressTracker.UpdateProcessMatcher.StandardCases.allCases.count
        
        let percentagePerOneStep: Double = Double(100/totalCases)
        
        /// The step number for switching update stages
        /// The number of packages that are being updated, divided by the number of process steps
        let incrementalProgress: Progress = .init(
            parent: updateProgressTracker.updateProgress,
            percentageOfParentToTakeUp: 100,
            totalItemsOfThisProgress: totalCases
        )
        
        // MARK: - Initialize the random progress trackers
        // These are random because you never know how many outputs you might get per stage, and it's better to give the users somethig to look at
        let downloadingStateProgress: Progress = .init(
            parent: incrementalProgress,
            percentageOfParentToTakeUp: percentagePerOneStep,
            totalItemsOfThisProgress: .random(in: 20...50)
        )
        
        let pouringStateProgress: Progress = .init(parent: incrementalProgress, percentageOfParentToTakeUp: percentagePerOneStep, totalItemsOfThisProgress: .random(in: 20...50))
        
        let cleanupStateProgress: Progress = .init(parent: incrementalProgress, percentageOfParentToTakeUp: percentagePerOneStep, totalItemsOfThisProgress: .random(in: 20...50))
        
        let backingUpStateProgress: Progress = .init(parent: incrementalProgress, percentageOfParentToTakeUp: percentagePerOneStep, totalItemsOfThisProgress: .random(in: 20...50))
        
        let linkingStateProgress: Progress = .init(parent: incrementalProgress, percentageOfParentToTakeUp: percentagePerOneStep, totalItemsOfThisProgress: .random(in: 20...50))
        
        // MARK: - Do the actual updating
        
        var consolidatedUnexpectedOutputs: [TerminalOutput] = .init()
        
        for await output in shell(AppConstants.shared.brewExecutablePath, ["upgrade", includeGreedyPackages ? "--greedy" : ""])
        {
            updateProgressTracker.insertOutput(output)
            
            output.match(as: UpdateProgressTracker.UpdateProcessMatcher.self)
            { standardOutputCase in
                
                self.appConstants.logger.debug("Matched \(output.description) as \(standardOutputCase)")
                
                fullUpdateStageTracker.currentStage = standardOutputCase
                
                switch standardOutputCase
                {
                case .downloading:
                    downloadingStateProgress.increment(bySetNumber: .random(in: 1...3))
                case .pouring:
                    pouringStateProgress.increment(bySetNumber: .random(in: 1...3))
                case .cleanup:
                    cleanupStateProgress.increment(bySetNumber: .random(in: 1...3))
                case .backingUp:
                    backingUpStateProgress.increment(bySetNumber: .random(in: 1...3))
                case .linking:
                    linkingStateProgress.increment(bySetNumber: .random(in: 1...3))
                }
                
                updateProgressTracker.updateProgress.setText(to: .belowBar(standardOutputCase.description))
                
            } onUnimplementedOutput:
            { unimplementedOutput in
                self.appConstants.logger.info("Unimplemented output for updater: \(unimplementedOutput.description, privacy: .public)")
                
                consolidatedUnexpectedOutputs.append(unimplementedOutput)
            }

        }
        
        if !consolidatedUnexpectedOutputs.isEmpty
        {
            throw .containsUnexpectedOutputs(consolidatedUnexpectedOutputs)
        }
    }
}

/*
 @MainActor
 func updatePackages(updateProgressTracker: UpdateProgressTracker, detailStage: UpdatingProcessDetails) async
 {
     let showRealTimeTerminalOutputs: Bool = UserDefaults.standard.bool(forKey: "showRealTimeTerminalOutputOfOperations")
     let includeGreedyPackages: Bool = UserDefaults.standard.bool(forKey: "includeGreedyOutdatedPackages")

     for await output in shell(AppConstants.shared.brewExecutablePath, ["upgrade", includeGreedyPackages ? "--greedy" : ""])
     {
         switch output
         {
         case .standardOutput(let outputLine):
             AppConstants.shared.logger.log("Upgrade function output: \(outputLine, privacy: .public)")

             if showRealTimeTerminalOutputs
             {
                 updateProgressTracker.realTimeOutput.append(RealTimeTerminalLine(line: outputLine))
             }

             if outputLine.contains("Downloading")
             {
                 detailStage.currentStage = .downloading
             }
             else if outputLine.contains("Pouring")
             {
                 detailStage.currentStage = .pouring
             }
             else if outputLine.contains("cleanup")
             {
                 detailStage.currentStage = .cleanup
             }
             else if outputLine.contains("Backing App")
             {
                 detailStage.currentStage = .backingUp
             }
             else if outputLine.contains("Moving App") || outputLine.contains("Linking")
             {
                 detailStage.currentStage = .linking
             }
             else
             {
                 detailStage.currentStage = .cleanup
             }

             AppConstants.shared.logger.info("Current updating stage: \(detailStage.currentStage.description, privacy: .public)")

             updateProgressTracker.updateProgress = updateProgressTracker.updateProgress + 0.1

         case .standardError(let errorLine):

             if showRealTimeTerminalOutputs
             {
                 updateProgressTracker.realTimeOutput.append(RealTimeTerminalLine(line: errorLine))
             }

             if errorLine.contains("tap") || errorLine.contains("No checksum defined for")
             {
                 updateProgressTracker.updateProgress = updateProgressTracker.updateProgress + 0.1

                 AppConstants.shared.logger.log("Ignorable upgrade function error: \(errorLine, privacy: .public)")
             }
             else
             {
                 AppConstants.shared.logger.warning("Upgrade function error: \(errorLine, privacy: .public)")
                 updateProgressTracker.errors.append("Upgrade error: \(errorLine)")
             }
         }
     }

     updateProgressTracker.updateProgress = 9
 }

 */
