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

extension UpdateProgressTracker
{
    @MainActor
    func updatePackages() async
    {
        let showRealTimeTerminalOutputs: Bool = Defaults[.showRealTimeTerminalOutputOfOperations]

        let includeGreedyPackages: Bool = Defaults[.includeGreedyOutdatedPackages]

        for await output in shell(AppConstants.shared.brewExecutablePath, ["upgrade", includeGreedyPackages ? "--greedy" : ""])
        {
            output.match(as: OutdatedPackagesTracker.UpdateProcessMatcher.self)
            { standardOutput in
                //self.currentStage = standardOutput
            }
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
