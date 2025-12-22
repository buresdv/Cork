//
//  Adopt Package.swift
//  Cork
//
//  Created by David Bureš - P on 07.10.2025.
//

import Foundation
import CorkShared
import CorkModels
import CorkTerminalFunctions

extension MassAppAdoptionView.MassAppAdoptionTacker
{
    @MainActor
    func adoptApp(
        _ appToAdopt: BrewPackagesTracker.AdoptableApp
    ) async -> AdoptionProcessResult
    {
        let (stream, process): (AsyncStream<StreamedTerminalOutput>, Process) = shell(AppConstants.shared.brewExecutablePath, ["install", "--cask", "--adopt", appToAdopt.selectedAdoptionCandidate.caskName])
        adoptionProcess = process
        
        var consolidatedOutput: (standardOutput: [String], standardError: [String]) = (standardOutput: .init(), standardError: .init())
        
        for await output in stream
        {
            switch output {
            case .standardOutput(let string):
                self.outputLines.append(.init(line: string))
                
                consolidatedOutput.standardOutput.append(string)
                
            case .standardError(let string):
                self.outputLines.append(.init(line: string))
                
                consolidatedOutput.standardError.append(string)
            }
        }
        
        AppConstants.shared.logger.debug("""
        Finished mass adoption process for cask \(appToAdopt.selectedAdoptionCandidate.caskName) with this result:
        Output: \(consolidatedOutput.standardOutput.joined())
        Error: \(consolidatedOutput.standardError.joined())
        """)
        
        if consolidatedOutput.standardError.isEmpty
        {
            AppConstants.shared.logger.info("Adoption process for cask \(appToAdopt.selectedAdoptionCandidate.caskName) was successful")
            
            return .success(appToAdopt)
        }
        else
        {
            AppConstants.shared.logger.error("Adoption process for cask \(appToAdopt.selectedAdoptionCandidate.caskName) failed")
            
            return .failure(
                .failedWithError(
                    failedAdoptionCandidate: appToAdopt,
                    error: consolidatedOutput.standardError.joined()
                )
            )
        }
    }
}
